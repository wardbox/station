---
title: Wiring the front door
date: 2026-06-02
summary: One small cluster, one ingress, one wildcard cert. Adding a subdomain should cost nothing.
readtime: 8 min
live: true
stack:
  - k3s
  - Traefik
  - Argo CD
  - cert-manager
filed:
  - infra
---

Everything this site is, the blog and every project, runs as its own workload
on one small cluster, behind one front door. Each piece deploys independently
and stays isolated. Adding a new subdomain should be cheap and ceremony-free.

## The shape

A single ingress controller does host-based routing: one subdomain is one
ingress rule, nothing more. DNS is a wildcard pointed at the cluster; TLS is a
wildcard cert from Let's Encrypt over DNS-01. A new subdomain needs zero DNS work
and zero cert work. That is the whole reason adding apps stays cheap.

## The loop

```text
push code → Actions builds + pushes image → bumps tag in git → Argo reconciles → live
```

Actions only builds. Argo only deploys, by reconciling a config repo. Git is the
single source of truth for what is running, and nothing holds cluster
credentials but the cluster. A blog post rides the same loop: commit a text
file, the image rebuilds, the tag bumps, Argo rolls it out.

You never touch `kubectl`.
