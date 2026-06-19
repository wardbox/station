---
title: How this site is built
date: 2026-06-19
summary: A plain walkthrough of the static blog, the container, and the small cluster behind it.
stack: [Astro, Content Collections, Caddy, Docker, k3s, Traefik, cert-manager, Argo CD, OpenTofu]
filed: [site, infra, gitops]
draft: true
---

## The shape

This site is deliberately small: Markdown files in git, Astro at build time, static files at runtime.

TODO: Describe the north star in your own words. Why this shape instead of a CMS, database, or app server?

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

TODO: Explain what you like about posting as a git push. Mention frontmatter, drafts, and calculated read time.

## Astro is the compiler

Astro reads the content collections, validates frontmatter, renders Markdown, and emits static HTML.

TODO: Walk through the important pieces:

- `src/content.config.ts` validates posts.
- `src/lib/content.ts` normalizes sections and paths.
- `src/pages/index.astro` builds the homepage.
- `src/pages/[type]/[...id].astro` builds post pages.
- `src/layouts/Base.astro` owns the document shell.

## The runtime is just Caddy

The production image has no Node process. The site is already built before it reaches runtime.

TODO: Explain the two-stage Dockerfile and why only `dist/` crosses into the Caddy image.

## The cluster

The blog runs as one Kubernetes workload in the `blog` namespace.

TODO: Explain the path from the pod to the public internet:

```text
Caddy pod → Service → Ingress → Traefik → wildcard TLS → stationsystems.dev
```

Mention `/healthz`, non-root runtime, dropped capabilities, and read-only root filesystem if useful.

## GitOps loop

GitHub Actions builds the image and updates the pinned digest. Argo CD deploys by reconciling git.

TODO: Explain why Actions does not deploy directly.

```text
push → build image → push GHCR → commit digest → Argo sync → rollout
```

## The substrate

OpenTofu creates the Hetzner network, firewall, server, and k3s bootstrap. It stops once the cluster exists.

TODO: Explain the boundary:

- OpenTofu owns cloud resources.
- Argo owns in-cluster desired state.
- Kubernetes owns running workloads.

## What I would change next

TODO: End with honest tradeoffs or next cuts. Possible notes:

- automate DNS records
- add an app template for subdomains
- decide how much project sites inherit from this design system
- add External Secrets Operator when a real secret-bearing app appears
