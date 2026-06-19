# Deferred launch plumbing

## OpenTofu remote state

`infra/tofu/versions.tf` already contains a commented S3 backend shape for Hetzner Object Storage with native OpenTofu locking. It is intentionally not enabled in this PR because migrating state requires real bucket credentials and a state move.

Manual next step:

1. In Hetzner Object Storage, create a private bucket such as `station-tofu-state` in `fsn1`.
2. Enable bucket versioning and keep server-side encryption on/default where available.
3. Create S3 credentials for that bucket; export them locally as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` or source `infra/tofu/.env`.
4. Uncomment and fill the backend block in `infra/tofu/versions.tf` with the real bucket name and endpoint.
5. From `infra/tofu`, run `tofu init -migrate-state` and confirm the migration only after reviewing the prompt.
6. Verify with `tofu state list`; do not commit `.terraform/`, `.env`, state, tfvars, or kubeconfig.

## Wildcard TLS / Gandi DNS-01

The live site currently uses cert-manager HTTP-01 for the apex host. Wildcard TLS requires DNS-01.

Gandi LiveDNS can be used with cert-manager through a webhook solver, but the credential is a Gandi Personal Access Token/API token stored in a Kubernetes Secret. This PR does not add the issuer because no scoped token/secret exists here, and committing or inventing one would be unsafe.

Manual next step:

1. Decide whether to keep DNS at Gandi or move the zone to Cloudflare.
2. If keeping Gandi, create the narrowest available Gandi token that can edit LiveDNS records for `stationsystems.dev`.
3. Install a maintained cert-manager Gandi webhook through Argo CD or Helm, then create the token Secret out-of-band in `cert-manager`.
4. Add a `ClusterIssuer` that references that Secret and issues `*.stationsystems.dev` + `stationsystems.dev` by DNS-01.
5. If Gandi token scoping is too broad for comfort, move authoritative DNS to Cloudflare and use cert-manager's built-in Cloudflare DNS-01 solver with a zone-scoped API token.
