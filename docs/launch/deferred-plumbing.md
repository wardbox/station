# Launch plumbing notes

## OpenTofu remote state

Remote state is active for the substrate composition in `infra/tofu`.

`infra/tofu/bootstrap-state` is the separate local-state bootstrap composition
that created the Hetzner Object Storage bucket and enabled versioning through
the MinIO provider. The substrate backend points at:

```text
bucket: station-tofu-state
key: substrate/terraform.tfstate
endpoint: https://fsn1.your-objectstorage.com
locking: native OpenTofu S3 lockfile
```

To use the migrated backend locally, source/export Object Storage credentials
before running substrate Tofu commands:

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
cd infra/tofu
tofu init
tofu state list
```

If credentials are stored as `TF_VAR_object_storage_access_key` /
`TF_VAR_object_storage_secret_key` for the bootstrap composition, map them to the
backend env vars before running commands in `infra/tofu`.

Do not commit `.terraform/`, `.env`, state, tfvars, kubeconfig, or local plan
files.

## Wildcard TLS / DNS-01

Wildcard TLS is active.

Current shape:

```text
DNS authority: Cloudflare
ClusterIssuer: letsencrypt-dns01-cloudflare
Certificate: stationsystems-dev-wildcard
Secret: stationsystems-dev-wildcard-tls
Hosts: stationsystems.dev, *.stationsystems.dev
Ingress: blog uses stationsystems-dev-wildcard-tls
```

The Cloudflare API token Secret is created out-of-band in the `cert-manager`
namespace and is not stored in git. Argo reconciles the issuer and certificate
manifests under `infra/k8s/cert-manager`.

Useful checks:

```bash
export KUBECONFIG=infra/tofu/kubeconfig.yaml
kubectl get clusterissuer letsencrypt-dns01-cloudflare
kubectl -n blog get certificate stationsystems-dev-wildcard
kubectl -n blog get secret stationsystems-dev-wildcard-tls
```

## Still deferred

- Automating DNS records themselves. Apex and wildcard records are currently
  managed at Cloudflare outside Tofu.
- Installing External Secrets Operator. Not needed until a workload requires
  credentials beyond the existing cert-manager DNS token.
- Moving controller bootstrap fully under Argo. Argo CD and cert-manager are
  tracked in `infra/k8s/bootstrap/*`, but still applied once with `kubectl`
  because they are the machinery that makes steady-state GitOps possible.
