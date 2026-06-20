# Kubernetes layer — front door

Layer 2 starts here. Argo CD owns the app set under `infra/k8s` after the
bootstrap below.

## DNS records

The domain is registered at Gandi, but authoritative DNS is Cloudflare. Until
DNS records are automated in Tofu, keep these records in Cloudflare DNS:

| Type | Name | Value | Purpose |
| --- | --- | --- | --- |
| A | `@` | `5.78.150.13` | apex site (`stationsystems.dev`) |
| A | `*` | `5.78.150.13` | wildcard subdomains for future apps |

Authoritative nameservers:

```text
adele.ns.cloudflare.com
logan.ns.cloudflare.com
```

Keep the apex and wildcard A records DNS-only, not proxied, while Traefik and
cert-manager own the public HTTPS edge.

## Bootstrap

The bootstrap layer is tracked as manifests under `infra/k8s/bootstrap`. Apply it
once after OpenTofu creates the cluster; after that, Argo reconciles
`infra/k8s` from `main`.

```bash
# First trust the control-plane host key: either pre-provision ~/.ssh/known_hosts
# or set SSH_HOST_KEY_SHA256 to the expected SHA256 fingerprint.
infra/k8s/fetch-kubeconfig.sh 5.78.150.13
export KUBECONFIG=$PWD/infra/tofu/kubeconfig.yaml
kubectl apply --server-side -k infra/k8s/bootstrap/argocd
kubectl apply --server-side -k infra/k8s/bootstrap/cert-manager
kubectl -n argocd rollout status deploy/argocd-server
kubectl -n cert-manager rollout status deploy/cert-manager
kubectl -n cert-manager rollout status deploy/cert-manager-webhook
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector
kubectl apply -f infra/k8s/argocd/station-k8s-app.yaml
kubectl -n argocd get application station-k8s
```

Do not commit Argo admin passwords, generated Secrets, or the Cloudflare API
token Secret. The root Argo Application is tracked in git; controller-generated
runtime state is not.

## cert-manager

The cert-manager controller stack and CRDs are bootstrapped from
`infra/k8s/bootstrap/cert-manager`. Issuers and Certificates are included in
`infra/k8s/kustomization.yaml`, so Argo keeps those reconciled after bootstrap.

## Private admin access with Tailscale

Admin surfaces should stay off the public internet. The Tailscale Kubernetes
Operator is installed from `tailscale/operator.yaml` and exposes Argo CD through
a tailnet-only LoadBalancer Service in `tailscale/argocd-service.yaml`.

Expected access path:

```text
Tailscale device -> http://argo.stationsystems.dev -> argocd.tail157fe.ts.net -> argocd-server Service -> Argo CD login
```

DNS has an explicit Cloudflare DNS-only CNAME:

```text
argo.stationsystems.dev -> argocd.tail157fe.ts.net
```

Because the target only resolves inside the tailnet, the friendly domain works
for Tailscale-connected devices without exposing Argo through public Traefik.

`argocd/server-insecure.yaml` makes Argo serve HTTP for this private tailnet
path. The traffic is still inside Tailscale's encrypted network, and Argo's own
login remains required.

Create the operator OAuth Secret out-of-band before syncing the operator; do not
commit Tailscale credentials:

```bash
export KUBECONFIG=infra/tofu/kubeconfig.yaml
kubectl -n tailscale create secret generic operator-oauth \
  --from-literal=client_id="$TS_OAUTH_CLIENT_ID" \
  --from-literal=client_secret="$TS_OAUTH_CLIENT_SECRET" \
  --dry-run=client -o yaml | kubectl apply -f -
```

The OAuth client should be scoped for the Kubernetes operator and allowed to tag
created devices with `tag:k8s-operator`. In Tailscale ACLs, make
`tag:k8s-operator` an owner of `tag:k8s`, then grant access to `tag:k8s` only to
the users/groups that should reach private admin services.

This replaces the public-Argo-subdomain idea. If Argo needs browser access, use
Tailscale/MagicDNS; keep `argo.stationsystems.dev` out of public Traefik.

For future apps, use the exposure wrappers documented in `apps/README.md`: add a
Tailscale LoadBalancer Service for private testing/admin access, or add a
Traefik Ingress when intentionally promoting something to the public internet.

## Current ingress

`blog/blog.yaml` routes only `Host: stationsystems.dev` to the blog workload.
TLS uses the wildcard Secret issued by the `letsencrypt-dns01-cloudflare`
ClusterIssuer in `cert-manager/issuer-cloudflare.yaml`. The Cloudflare API token
Secret is created out-of-band in the `cert-manager` namespace and is not stored
in git. HTTP is redirected to HTTPS globally by the k3s Traefik
`HelmChartConfig` in `traefik/https-redirect.yaml`.

On pushes to `main`, GitHub Actions builds and pushes the GHCR image, then
commits the new image digest to `blog/blog.yaml`. Actions has no cluster
credentials; Argo CD rolls out the committed digest.

The older `letsencrypt-http01` ClusterIssuer is left in place for now as a
working fallback. New subdomains should use DNS-01/wildcard TLS.
