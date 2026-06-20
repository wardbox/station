---
title: How this site is built
date: 2026-06-19
summary: Markdown in git, Astro at build time, Caddy at runtime, and a small k3s cluster behind the door.
filed: [site, infra, gitops]
draft: false
---

## The shape

This site is deliberately small: Markdown files in git, Astro at build time, static files at runtime.

I just wanted a place where I could put small writings and showcase sites I build on one domain. It should feel more like building blocks than an app.

```text
Markdown → Astro build → static dist/ → Caddy container → k3s → Traefik → web
```

## Content is the CMS

Posts live under `src/content`:

```text
src/content/writing/
src/content/builds/
src/content/notes/
```

This makes me focus on writing instead of all the other bits, and I can write from within the same place I spend most of my time. Creating, editing, publishing, and deleting posts are all just file changes.

## Astro is the compiler

Astro reads the content collections, validates frontmatter, renders Markdown, and emits static HTML.

- `src/content.config.ts` validates posts.
- `src/lib/content.ts` normalizes sections and paths.
- `src/pages/index.astro` builds the homepage.
- `src/pages/[type]/[...id].astro` builds post pages.
- `src/layouts/Base.astro` owns the document shell.

## The runtime is just Caddy

The production image has no Node process. We build the static Astro site and throw Caddy at it. This keeps it small and requires very minimal resources to run.

## The cluster

The blog runs as one Kubernetes workload in the `blog` namespace. We're using k3s because it lets this stay small without becoming a snowflake VPS. For just the blog alone even serving on k3s is overkill, but I want this to be modular and allow for future development while also keeping me familiar with Kubernetes. k3s also ships the boring pieces I need here: Traefik, ServiceLB, CoreDNS, and local-path storage.

There's a container running Caddy on port `8080`. From within the pod, we've got access to it at `localhost:8080` serving the static site.

Kubernetes spins up that pod with a `blog` label. Then a Service gives the pod a stable internal address. The Service is just saying: send traffic for this Service to pods with that label, targeting port `8080`. Pod IPs can change; the Service is the stable thing other Kubernetes objects can point at.

Then there is the Ingress: for HTTPS requests with host `stationsystems.dev`, route `/` to the blog Service and use the wildcard TLS secret. That gives me room to spin up `app.stationsystems.dev` in the future, or whatever else I need. Ingress isn't a proxy, just a routing rule really.

Traefik is the reverse proxy receiving public traffic though, and it's what implements the Ingress.

For TLS, cert-manager gets a certificate from Let's Encrypt using DNS-01. Cloudflare handles the DNS challenge because it is authoritative for the zone. The certificate covers root and wildcard.

Traefik is exposed by k3s ServiceLB, comes by default with k3s.

And then DNS points the domain to the node IP with an A record, technically two, one for the apex and one for the wildcard.

```text
stationsystems.dev → Traefik/TLS → Ingress → Service → Caddy pod
```

## GitOps loop

GitHub Actions builds the image and updates the pinned digest. Argo CD deploys by reconciling git.

We wanna keep GitHub Actions out of doing Argo CD's job, so it just handles the build.

```text
push → build image → push GHCR → commit digest → Argo sync → rollout
```

## The substrate

OpenTofu creates the Hetzner network, firewall, server, and k3s bootstrap. It stops once the cluster exists.

- OpenTofu owns cloud resources.
- Argo owns in-cluster desired state.
- Kubernetes owns running workloads.

## What I would change next

- automate DNS records
- add an app template for subdomains
- decide how much project sites inherit from this design system
- add External Secrets Operator when a real secret-bearing app appears
