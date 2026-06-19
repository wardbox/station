# Launch plumbing notes

## OpenTofu remote state

Remote state is active for the substrate composition in `infra/tofu`.

`infra/tofu/bootstrap-state` is the separate local-state bootstrap composition that created the Hetzner Object Storage bucket and enabled versioning through the MinIO provider. The substrate backend now points at:

```text
bucket: station-tofu-state
key: substrate/terraform.tfstate
endpoint: https://fsn1.your-objectstorage.com
locking: native OpenTofu S3 lockfile
```

To use the migrated backend locally, source/export Object Storage credentials before running substrate Tofu commands:

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
cd infra/tofu
tofu init
tofu state list
```

If credentials are stored as `TF_VAR_object_storage_access_key` / `TF_VAR_object_storage_secret_key` for the bootstrap composition, map them to the backend env vars before running commands in `infra/tofu`. Do not commit `.terraform/`, `.env`, state, tfvars, kubeconfig, or local plan files.

## Wildcard TLS / Gandi DNS-01

The live site currently uses cert-manager HTTP-01 for the apex host. Wildcard TLS requires DNS-01.

Gandi LiveDNS can be used with cert-manager through a webhook solver, but the credential is a Gandi Personal Access Token/API token stored in a Kubernetes Secret. This PR does not add the issuer because no scoped token/secret exists here, and committing or inventing one would be unsafe.

Manual next step:

1. Decide whether to keep DNS at Gandi or move the zone to Cloudflare.
2. If keeping Gandi, create the narrowest available Gandi token that can edit LiveDNS records for `stationsystems.dev`.
3. Install a maintained cert-manager Gandi webhook through Argo CD or Helm, then create the token Secret out-of-band in `cert-manager`.
4. Add a `ClusterIssuer` that references that Secret and issues `*.stationsystems.dev` + `stationsystems.dev` by DNS-01.
5. If Gandi token scoping is too broad for comfort, move authoritative DNS to Cloudflare and use cert-manager's built-in Cloudflare DNS-01 solver with a zone-scoped API token.
