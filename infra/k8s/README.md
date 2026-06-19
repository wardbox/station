# Kubernetes layer — front door

Layer 2 starts here. Argo CD owns the app set under `infra/k8s` after the
bootstrap below.

## DNS records

The domain is registered at Gandi. Until DNS is automated, configure these in
Gandi LiveDNS:

| Type | Name | Value | Purpose |
| --- | --- | --- | --- |
| A | `@` | `5.78.150.13` | apex site (`stationsystems.dev`) |
| A | `*` | `5.78.150.13` | wildcard subdomains for future apps |

Use the default TTL or `300` while wiring the front door.

## Argo CD bootstrap

Argo CD itself is bootstrapped once by hand; after that, it reconciles
`infra/k8s` from `main`.

```bash
export KUBECONFIG=$PWD/infra/tofu/kubeconfig.yaml
kubectl apply -f infra/k8s/argocd/namespace.yaml
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server
kubectl apply -f infra/k8s/argocd/station-k8s-app.yaml
kubectl -n argocd get application station-k8s
```

Do not commit Argo admin passwords or generated Secrets.

## cert-manager

cert-manager was installed by hand before this GitOps cut:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.2/cert-manager.yaml
kubectl -n cert-manager rollout status deploy/cert-manager
kubectl -n cert-manager rollout status deploy/cert-manager-webhook
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector
```

The issuer is now included in `infra/k8s/kustomization.yaml`, so Argo keeps
it reconciled. Installing cert-manager itself through Argo is a later bootstrap
cleanup, not needed for the static blog launch.

## Current ingress

`blog/blog.yaml` routes only `Host: stationsystems.dev` to the blog workload.
TLS is issued by cert-manager using the `letsencrypt-http01` ClusterIssuer in
`cert-manager/issuer.yaml`. HTTP is redirected to HTTPS globally by the k3s
Traefik `HelmChartConfig` in `traefik/https-redirect.yaml`.

On pushes to `main`, GitHub Actions builds and pushes the GHCR image, then
commits the new image digest to `blog/blog.yaml`. Actions has no cluster
credentials; Argo CD rolls out the committed digest.

This is the first TLS cut for the apex. A wildcard certificate still needs a
DNS-01 issuer once DNS provider automation is chosen. See
`docs/launch/deferred-plumbing.md` for the exact remote-state and wildcard TLS
next steps.
