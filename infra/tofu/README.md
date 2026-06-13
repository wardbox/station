# OpenTofu build-out — the substrate

How we provision the cluster's substrate with OpenTofu. This is the
**implementation plan** for build-spec layer 1 ("OpenTofu — the substrate.
Hetzner VMs, network, DNS, k3s bootstrap. Ends at *the cluster exists*.").

It's a plan, not orders — same posture as the specs. Where a thing needs a
decision from you, it's in **Decisions needed** or **Left open**, not faked.

References that shaped this:
[terraform-best-practices.com](https://www.terraform-best-practices.com/) and
[HashiCorp recommended practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices).
k3s-on-Hetzner wiring informed by [hetzner-k3s](https://hetzner-k3s.com/) (we
hand-roll rather than adopt the tool, but borrow its conventions: pinned k3s
version, private-network flannel, firewalled SSH/API).

---

## Status

**Built + validated (`tofu validate` clean):**
- `modules/network` — private network, subnet, firewall.
- `modules/cluster` — stable public IP, placement group, control plane + agents,
  cloud-init k3s bootstrap (pinned version), automatic kubeconfig fetch.
- Composition wiring, variables, outputs, tooling (`.editorconfig`, `.tflint.hcl`,
  `.gitignore`, `.env.example`, `terraform.tfvars.example`).

**Decided since first draft:**
- k3s: hand-rolled cloud-init (not `kube-hetzner`), to keep Tofu thin and let
  Argo own everything inside the cluster. Keep k3s defaults (Traefik + ServiceLB
  + local-path); Hetzner CCM/CSI come later via Argo.
- State: **Hetzner Object Storage** (EU-only — FSN1/NBG1/HEL1; fine, state has no
  latency needs) via the S3 backend with `use_lockfile` native locking. Wired but
  commented in `versions.tf` until the bucket exists.

**Pending:**
- `modules/dns` — waiting on the domain decision.
- First real `apply` — waiting on you (token + `terraform.tfvars` + Object Storage
  bucket if going remote-state-first).

---

## Scope — what Tofu owns, and where it stops

Tofu owns everything up to and including **"a running k3s cluster I can talk to
with a kubeconfig."** Then it stops. Everything *inside* the cluster — Argo CD,
Traefik config, cert-manager, the Hetzner CCM/CSI, the apps — is layer 2 (Argo),
not Tofu. This is the build spec's three-layer split, kept honest.

**Tofu provisions:**
- Hetzner project plumbing: SSH key, private network + subnet, firewall(s),
  placement group.
- Servers: 1 control-plane node + 1–2 agent nodes (start small).
- k3s itself, bootstrapped via cloud-init on first boot.
- DNS: the wildcard `*.stationsystems.dev` record pointing at the entry point.
- Outputs: the kubeconfig and the entry-point IP, for layer 2 to consume.

**Tofu does NOT provision (these are Argo's job, layer 2):**
- Hetzner Cloud Controller Manager / CSI driver — installed *in* the cluster as
  apps Argo manages (they just need the hcloud token as an in-cluster secret).
- Ingress rules, TLS issuers, cert-manager, ESO, the blog/app workloads.

Drawing the line here keeps the Tofu surface tiny and the blast radius small
(best-practices: "insulate unrelated resources… smaller compositions").

---

## Decisions needed before we write `.tf`

1. **State backend.** Tofu state must live in a remote, locking, versioned
   backend — never the laptop, never git (both guides are emphatic). Options:
   - **Hetzner Object Storage** (S3-compatible, same regions) — keeps everything
     in one provider. Leaning choice.
   - **Cloudflare R2 / Backblaze B2 / AWS S3** — alternatives; R2 and S3 support
     OpenTofu 1.10+ native locking (`use_lockfile`, no DynamoDB needed).
   - Decision: confirm Hetzner Object Storage, or name an alternative.
2. **DNS provider for `stationsystems.dev`.** Where is DNS hosted today? This
   sets both the wildcard record resource *and* the cert-manager DNS-01 solver
   later (Cloudflare, Hetzner DNS, Route53…). If it's movable, **Hetzner DNS**
   keeps it one-provider; **Cloudflare** is the most common DNS-01 path.
3. **Region.** Build spec says Hillsboro, OR = `hil`. Confirm (Ashburn = `ash`
   is the other US option).
4. **Node sizes + arch.** Start small. Suggested opening position:
   - Control plane: `cax11` (arm64, 2 vCPU / 4 GB) or `cpx21` (amd64, 3 vCPU / 4 GB).
   - Agents: 1–2 × `cax21` (arm64, 4 vCPU / 8 GB) or `cpx21`.
   - **arch matters downstream:** it settles the `platforms:` line we left open
     in `.github/workflows/build.yml`. arm64 (`cax*`) is cheaper; pick it unless
     something needs amd64.
5. **Image format on disk for k3s nodes.** Plain Ubuntu 24.04 + k3s install
   script (simple, what this plan assumes) vs. openSUSE MicroOS (immutable, what
   `kube-hetzner` uses). Leaning plain Ubuntu for a hand-rolled start.

---

## First-time Hetzner setup (you've not made an account)

A one-time, click-through walkthrough. Tofu can't bootstrap its own credentials,
so this part is by hand (the build spec's "irreducible root").

1. **Create the account.** <https://console.hetzner.cloud> → sign up. Hetzner
   Cloud (not Robot/dedicated). Expect an identity/payment verification step.
2. **Create a Project.** The console is organized into projects; make one named
   e.g. `station`. All API tokens are scoped to a single project.
3. **Generate an API token.** Project → *Security* → *API Tokens* → *Generate*.
   Give it **Read & Write**. Copy it once (shown only once). This is the single
   credential Tofu uses.
4. **Add your SSH public key** (optional via console — Tofu will manage it, but
   having it handy is useful): *Security* → *SSH Keys*. We'll feed the public key
   to Tofu as a variable.
5. **Enable Object Storage** (if we pick it for state): *Object Storage* → create
   a bucket + S3 credentials (access key / secret). Same region as the cluster.
6. **Hand me, out of band:** nothing committed. You'll export the token locally:
   ```bash
   export HCLOUD_TOKEN="…"          # Tofu's hcloud provider reads this
   # or: export TF_VAR_hcloud_token="…"
   ```
   The token never enters git, `.tfvars`, or state output.

> Cost note: the suggested 3-node arm64 start is roughly in the low-tens of
> €/month. We'll confirm exact sizes before applying. Nothing is provisioned
> until you run `tofu apply` with your token present.

---

## Principles we're adopting (distilled, mapped)

| Principle | Source | How we apply it |
|---|---|---|
| Remote state, never laptop/git | both | S3-compatible backend, versioned + locking |
| Encrypt state | OpenTofu | native **state encryption** on top of the backend |
| No manual changes | HashiCorp | Tofu owns the substrate; no clicking in the console after bootstrap |
| Small compositions, small blast radius | both | thin modules, one state for the substrate; cluster-internal stuff is Argo's |
| `main`/`variables`/`outputs`/`versions` split | TBP | every module follows it |
| `tfvars` only in the composition | TBP | root composition only; modules take explicit inputs |
| Naming: `_` not `-`, no type-repeat, `this`, singular | TBP | enforced in review + tflint |
| `description`/`type`/`default`/`validation` order; `nullable=false`; positive names | TBP | enforced in `variables.tf` |
| `terraform fmt`, pre-commit, terraform-docs, `.editorconfig` | TBP | wired before first real apply |
| Plan-on-PR, apply-on-merge; version-control everything | HashiCorp | local plan/apply first, CI plan later (see Workflow) |

---

## Repository layout (monorepo)

Infra lives beside the blog. The substrate composition is small and flat; reusable
pieces are modules it calls.

```text
infra/
  tofu/
    README.md              ← this plan
    .editorconfig          ← 2-space, trim trailing ws
    .tflint.hcl            ← lint rules
    versions.tf            ← required_version + provider versions + backend
    providers.tf           ← hcloud (+ dns) provider config, state encryption
    main.tf                ← calls modules, locals, data sources
    variables.tf           ← composition inputs
    outputs.tf             ← kubeconfig, entry IP, network id
    terraform.tfvars       ← gitignored (real values)
    terraform.tfvars.example  ← committed template, no secrets
    modules/
      network/             ← private network + subnet + firewall
        {main,variables,outputs,versions}.tf
      cluster/             ← servers + cloud-init k3s bootstrap + placement group
        {main,variables,outputs,versions}.tf
        templates/
          server-init.yaml.tftpl   ← cloud-init for the control-plane node
          agent-init.yaml.tftpl    ← cloud-init for agents
      dns/                 ← wildcard record at the entry point
        {main,variables,outputs,versions}.tf
  k8s/                     ← (later, layer 2) Argo CD, ApplicationSets, app templates
```

`terraform.tfvars` is the *only* place real values live, and it's gitignored.
The `.example` is the committed, documented template.

---

## Modules (by intent, with shape)

### `modules/network`
- **Creates:** `hcloud_network` + `hcloud_network_subnet` (private 10.x), a
  `hcloud_firewall` (allow SSH from your IP, k3s API 6443 from your IP, intra-network
  all, HTTP/HTTPS 80/443 from the world to the ingress entry point).
- **Inputs:** `network_cidr`, `subnet_cidr`, `allowed_admin_cidrs` (your IP/32),
  `name_prefix`.
- **Outputs:** `network_id`, `subnet_id`, `firewall_id`.

### `modules/cluster`
- **Creates:** `hcloud_placement_group` (spread), `hcloud_ssh_key`, the
  control-plane `hcloud_server` and N agent `hcloud_server`s, each attached to the
  private network and firewall, each with `user_data` from a cloud-init template
  that installs k3s.
  - Control plane: `curl -sfL https://get.k3s.io | … server` with
    `--disable traefik`? **No** — k3s ships Traefik and the build spec uses it as
    the one front door, so we *keep* Traefik. We do set
    `--kubelet-arg cloud-provider=external` so the Hetzner CCM (installed later by
    Argo) owns node lifecycle / LoadBalancer services. Token generated by Tofu
    (`random_password`), passed to agents.
  - Agents: join via the server's private IP + token.
- **Inputs:** `server_type`, `agent_count`, `agent_server_type`, `location`,
  `image`, `network_id`, `subnet_id`, `firewall_id`, `ssh_public_key`, `k3s_token`.
- **Outputs:** `control_plane_ipv4` (entry point), `kubeconfig` (sensitive),
  `node_names`.
- **Bootstrap detail:** the kubeconfig is fetched from the server after k3s is up
  (remote-exec/`ssh` read of `/etc/rancher/k3s/k3s.yaml`, server address rewritten
  to the public IP). This is the one ordering subtlety; documented in the module.

### `modules/dns`
- **Creates:** the wildcard `*.stationsystems.dev` A record (and the apex) pointing
  at `control_plane_ipv4` (or a load balancer later). Provider depends on the DNS
  decision above.
- **Inputs:** `zone`, `target_ipv4`.
- **Outputs:** `fqdn_wildcard`.

> A `hcloud_load_balancer` in front of the nodes is **left open** — for a
> single-server start it's an unneeded cost; add it when there's >1 ingress node.

---

## State management

- **Backend:** S3-compatible (Hetzner Object Storage, pending decision), with
  bucket **versioning on** and **native locking** (`use_lockfile = true`, OpenTofu
  1.10+ — no DynamoDB table needed).
- **Encryption:** OpenTofu **native state encryption** layered on top, so state is
  ciphertext at rest even inside the bucket. Key sourced from an env var / external
  KMS, never committed.
- **One state for the substrate composition.** Layer 2 (Argo/k8s) gets its own
  state or is pure GitOps (no Tofu state at all) — kept separate, per "smaller
  blast radius."
- State outputs that other layers need (kubeconfig, entry IP) are consumed via
  `terraform_remote_state` or written to a secret manager — **not** copy-pasted.

---

## Secrets handling

- **hcloud token:** env var `HCLOUD_TOKEN` (or `TF_VAR_hcloud_token`). Never in
  git, `.tfvars`, or committed output.
- **k3s token:** generated by Tofu (`random_password`), lives only in state — which
  is why state is encrypted + access-controlled.
- **Object Storage creds (if used for state):** env vars
  (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`), out of band.
- **Sensitive outputs** marked `sensitive = true`. No secrets echoed in plan output.
- Aligns with TBP "Managing Secrets": keep material out of config/state where
  possible; what must live in state is encrypted.

---

## Conventions & tooling

- `tofu fmt` is law (non-negotiable, non-configurable). CI runs `tofu fmt -check`.
- **pre-commit** (`antonbabenko/pre-commit-terraform`): `terraform_fmt`,
  `terraform_validate`, `terraform_tflint`, `terraform_docs`.
- **`.editorconfig`:** 2-space indent for `*.tf`/`*.tfvars`, trim trailing
  whitespace.
- **terraform-docs** auto-generates each module's input/output tables into its
  README.
- **Comments:** `#` only; section headers as `# -----` blocks.
- **Naming:** `_` not `-` in Tofu identifiers; lowercase; don't repeat the resource
  type in the name; `this` for a module's single resource of a type; singular
  nouns; plural names for `list`/`map` variables.
- **Variables:** ordered `description` → `type` → `default` → `validation`; always
  a `description`; `nullable = false` unless null is meaningful; positive names
  (`encryption_enabled`, not `_disabled`); `validation` blocks for constrained
  inputs (region, server_type, counts).

---

## Workflow (maturity-aware)

Following HashiCorp's "evolve your practices" ladder, pragmatically:

1. **Now (semi-automation):** run `tofu plan` / `apply` locally with the token in
   env. Everything is version-controlled; the console is read-only after bootstrap
   (no manual changes — drift is a bug).
2. **Soon (IaC in CI):** a `tofu plan` job on PRs touching `infra/tofu/**` (no
   apply, no creds beyond read), posting the plan for review. This mirrors the
   blog's build-only CI ethos: PRs validate, they don't mutate.
3. **Later (collaborative IaC):** gated `apply` on merge to `main` via an
   environment with the token as a protected secret, if/when it's worth it. Apply
   stays a deliberate, reviewed step — never automatic clicking.

No manual changes in the Hetzner console once Tofu owns a resource. If the console
and the code disagree, the code wins and we reconcile.

---

## Validation

- `tofu fmt -check -recursive`
- `tofu validate` (per module + composition)
- `tflint` with the hcloud ruleset
- `tofu plan` against a real (or `-refresh=false`) target before any apply
- Optional security scan: `trivy config` / `checkov` on the `.tf`

Locally, all of the above run with **zero cloud calls** except `plan`/`apply`, so
the structure can be validated before you ever create the Hetzner account.

---

## Build order (what we'll actually do, in sequence)

1. Land this artifact (this PR). No `.tf` yet.
2. You: make the Hetzner account + token; answer **Decisions needed**.
3. Scaffold `infra/tofu/` — `versions.tf`, `providers.tf`, `.editorconfig`,
   `.tflint.hcl`, `.gitignore` entries, empty modules — all `tofu validate`-clean
   with **no** resources. Verifiable locally without a token.
4. `modules/network` → plan only.
5. `modules/cluster` (cloud-init k3s) → first real `apply`: cluster exists,
   kubeconfig output. `kubectl get nodes` works.
6. `modules/dns` → wildcard record resolves.
7. Hand off: kubeconfig + entry IP become layer-2 (Argo) inputs.

---

## Left open

- Load balancer in front of ingress (cost vs. single-node simplicity).
- HA control plane (3 servers + etcd) — a later move if uptime justifies it.
- Node autoscaling (Cluster Autoscaler has a Hetzner provider; Karpenter doesn't).
- Whether layer 2 is pure GitOps (no Tofu state) or a second small composition.
- Ubuntu + k3s script vs. MicroOS immutable nodes (and whether to adopt the
  community `kube-hetzner` module instead of hand-rolled — saves time, costs
  control/learning; this plan assumes hand-rolled-but-minimal).
