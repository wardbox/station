# Site — build spec

Companion to `site-design-spec.md`. Same rule: intent, not orders. Each
principle states its reasoning so undecided details can be resolved from
principle later. Where a thing is genuinely undecided, it's in **Left open** —
not faked.

---

## North star

Everything the site is — the blog and every project — runs as its own workload
on one small cluster, behind one front door. Each piece is independently
deployable and isolated. Adding a new subdomain is cheap and ceremony-free.

Mirrors the design spec: each project is its own surface, but they all live
behind one coherent entrance.

---

## Substrate

**Hetzner Cloud** VMs (Hillsboro, OR region — low latency, 20 TB egress
included, flat pricing) running **k3s** (lightweight k8s — single binary,
Traefik + a service load-balancer + local-path storage built in; full k8s is
overkill here). Provisioned with **OpenTofu** — it owns everything up to and
including "the cluster exists," then stops.

Start small: one server node + one or two agents. HA control plane is a later
move if uptime ever justifies it, not a day-one requirement. Anything stateful
(Postgres) gets a Hetzner block volume via its CSI driver, not node-local disk —
so a node can die without taking data with it.

Node count: small to start; node autoscaling is an option (Cluster Autoscaler
has a Hetzner provider — Karpenter does not, so it's out).

---

## Principles

1. **One workload per thing.** The blog and each app are separate Deployments,
   each in its own namespace. The blast radius of a bad deploy or a crash is one
   app — never the whole site.

2. **One front door.** A single ingress controller (Traefik) does host-based
   routing: the apex → the blog, `carbon.<domain>` → the carbon app, etc. Adding
   a subdomain is *an ingress rule*, nothing more.

3. **Wildcard everything.** `*.<domain>` DNS points at the cluster; `*.<domain>`
   TLS comes from cert-manager + Let's Encrypt via DNS-01. A new subdomain needs
   zero DNS and zero cert work. This is the whole reason adding apps stays cheap.

4. **Each app owns its state.** An app's database belongs to that app, not to a
   shared global store every service reaches into. Isolation over convenience —
   one app's data problem shouldn't be everyone's. (Exact Postgres shape: open.)

5. **Templated, not bespoke.** A per-app Helm chart (or kustomize base): new app
   = copy values, set the host and image, deploy. Resist snowflake manifests —
   the Esse-starter instinct, applied to infra.

6. **Build and deploy are separate jobs.** GitHub Actions only *builds* — image
   to GHCR, then a tag bump committed to the config repo. Argo CD *deploys* by
   reconciling that repo. No clicking, no manual `kubectl`. Actions never holds
   cluster credentials. Git is the source of truth for what's running.

7. **Posting is a git push.** A new post = commit a text file; Actions rebuilds
   the blog and rolls it out. Writing must never require touching the cluster.

8. **Weight-matched.** The blog stays featherweight — a tiny static server
   handing out HTML built from your text. Apps carry their full stack. Don't
   inflate the blog to match the apps.

---

## The shape (by intent)

- **Ingress** — Traefik (k3s built-in), host-based routing per subdomain.
- **TLS / DNS** — cert-manager + Let's Encrypt DNS-01 issuing a wildcard cert;
  a wildcard A/AAAA record at the cluster's entry point.
- **Blog workload** — minimal static container, content baked at build time.
- **App workload** — Wasp client + server (+ its own Postgres), own namespace.
- **Registry** — GHCR.
- **Build** — per-repo GitHub Actions: build → push to GHCR → bump image tag in
  the config repo. Build only; never deploys.
- **Deploy** — Argo CD reconciles the config repo into the cluster.
- **Per-app template** — one Argo ApplicationSet generates an app per subdomain
  from a single parameterized template (host, image, env).
- **Secrets** — none needed at launch (static blog). ESO + external backend when
  the first credentialed app lands. See Secrets section.

---

## Orchestration

Three layers, git as the single source of truth. Each layer stops cleanly where
the next begins.

1. **OpenTofu — the substrate.** Hetzner VMs, network, DNS, k3s bootstrap.
   Ends at "the cluster exists."
2. **Argo CD — everything inside the cluster.** One config repo describes desired
   state; Argo continuously reconciles reality to it. ApplicationSets generate
   one app per subdomain from a template, so a new subdomain is: add an entry,
   commit, done. This is both the per-app template *and* the orchestration story
   — same object. Everything else (KEDA, Postgres operator, etc.) is just another
   app Argo manages, not a separate system.
3. **GitHub Actions — build only.** Code push → build image → push to GHCR →
   bump the tag in the config repo. Argo takes it from there.

**The loop:**
```text
push code → Actions builds + pushes image → bumps tag in git → Argo reconciles → live
```
A blog post is the same loop: commit a text file → Actions rebuilds the blog
image → tag bump → Argo rolls it. You never touch kubectl.

Optional, later: **Argo Workflows** for real multi-step pipelines (e.g. a
carbon-data job — pull, process, store, trigger). It's a workload Argo CD
deploys, not a fourth layer.

---

## Secrets

**Not needed at launch.** The blog is static text with no credentials — don't
build a secrets layer for a problem that doesn't exist yet. The trigger is the
first app that actually needs a credential (Postgres, an API key, the carbon
app's WattTime token). Until then, this section is a parked decision, not a task.

**When the time comes: External Secrets Operator (ESO), external backend.**
The reasoning, so it isn't re-litigated:

- The whole premise is "everything in git, but secrets never in git" — and git
  history is permanent, so a plaintext slip is exposed forever in every clone.
  That rules out the encrypt-into-the-repo camp (Sealed Secrets, SOPS): they
  still place *material* (ciphertext) in a world-readable repo. ESO puts nothing
  in git but a *reference*.
- ESO is the de facto standard for syncing from an external store into k8s
  Secrets, and it's just another app Argo manages — consistent with everything
  else here.

**Backend — choose when triggered, not now:**
- *Cloud secret manager* (AWS/GCP) — lives off-cluster, so a cluster compromise
  doesn't also own the vault; better separation to put on public display; tiny
  cost. The leaning default for a showcase.
- *Self-hosted Infisical* — open-source, free, fully self-hosted, but the vault
  then runs on the same cluster it serves. Fine for a portfolio; weaker isolation.

**Hardening to apply at that point:** namespaced `SecretStore` (not
`ClusterSecretStore`) to limit blast radius; etcd encryption at rest via a KMS
provider; GitHub push protection on as a backstop against accidental plaintext
commits. The irreducible root persists — ESO needs one credential to reach the
backend, seeded out-of-band. (Cloud *workload identity* eliminates static creds
entirely, but it's cloud-specific — a "when you touch AWS" note, not for Hetzner.)

---

## Anti-goals

- One giant pod running everything — kills isolation and independent deploys.
- Manual `kubectl` as the deploy path — Argo reconciles, or it didn't happen.
- Actions deploying directly / holding cluster credentials — it builds, nothing more.
- Per-subdomain DNS or cert toil — wildcards exist precisely to avoid this.
- Snowflake manifests per app — template instead.
- A heavyweight blog — it's text; keep it light.
- A shared mutable Postgres every app dips into — unless deliberately chosen.

---

## Left open

- Node count, and whether/when node autoscaling (Cluster Autoscaler) or an HA
  control plane is worth it.
- **Postgres** — leaning CloudNativePG (declarative, HA, WAL backups + PITR to
  object storage, solves data + backups in one). Per-app StatefulSet or external
  managed still possible. Whatever it is, it stays *app-owned* (Principle 4).
- **Backups** — CloudNativePG covers Postgres if chosen; cluster-state backups
  (Velero → object storage) still need a decision. Settle *before* anything
  you'd miss lives here.
- Blog content format on disk — the thing that makes "drop a post" frictionless.
  Shared open item with the design spec.
