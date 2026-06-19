# Kubernetes layer — front door

Layer 2 starts here. These manifests are still applied by hand until Argo CD owns
this directory.

## DNS records

The domain is registered at Gandi. Until DNS is automated, configure these in
Gandi LiveDNS:

| Type | Name | Value | Purpose |
| --- | --- | --- | --- |
| A | `@` | `5.78.150.13` | apex site (`stationsystems.dev`) |
| A | `*` | `5.78.150.13` | wildcard subdomains for future apps |

Use the default TTL or `300` while wiring the front door.

## cert-manager

Installed by hand until Argo CD owns layer 2:

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.2/cert-manager.yaml
kubectl -n cert-manager rollout status deploy/cert-manager
kubectl -n cert-manager rollout status deploy/cert-manager-webhook
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector
kubectl apply -f cert-manager/issuer.yaml
```

## Current ingress

`blog/blog.yaml` routes only `Host: stationsystems.dev` to the blog workload.
TLS is issued by cert-manager using the `letsencrypt-http01` ClusterIssuer in
`cert-manager/issuer.yaml`. HTTP is redirected to HTTPS globally by the k3s
Traefik `HelmChartConfig` in `traefik/https-redirect.yaml`.

This is the first TLS cut for the apex. A wildcard certificate still needs a
DNS-01 issuer once DNS provider automation is chosen.
