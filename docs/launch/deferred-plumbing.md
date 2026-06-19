# Deferred launch plumbing

## OpenTofu remote state

`infra/tofu/bootstrap-state` now contains a separate local-state bootstrap composition that creates the Hetzner Object Storage bucket and enables versioning through the MinIO provider. The main substrate state is intentionally not migrated in this PR because migration requires real Object Storage credentials and a reviewed state move.

Manual next step:

1. Create Hetzner Object Storage S3 credentials out-of-band.
2. Export them locally as `TF_VAR_object_storage_access_key` and `TF_VAR_object_storage_secret_key`.
3. Copy `infra/tofu/bootstrap-state/terraform.tfvars.example` to a local `terraform.tfvars`, choose the bucket name/region/server, and do not commit it.
4. From `infra/tofu/bootstrap-state`, run `tofu init`, `tofu plan`, and `tofu apply`.
5. Copy the output bucket/endpoint values into the commented backend block in `infra/tofu/versions.tf`.
6. From `infra/tofu`, run `tofu init -migrate-state` and confirm the migration only after reviewing the prompt.
7. Verify with `tofu state list`; do not commit `.terraform/`, `.env`, state, tfvars, or kubeconfig.

## Wildcard TLS / Gandi DNS-01

The live site currently uses cert-manager HTTP-01 for the apex host. Wildcard TLS requires DNS-01.

Gandi LiveDNS can be used with cert-manager through a webhook solver, but the credential is a Gandi Personal Access Token/API token stored in a Kubernetes Secret. This PR does not add the issuer because no scoped token/secret exists here, and committing or inventing one would be unsafe.

Manual next step:

1. Decide whether to keep DNS at Gandi or move the zone to Cloudflare.
2. If keeping Gandi, create the narrowest available Gandi token that can edit LiveDNS records for `stationsystems.dev`.
3. Install a maintained cert-manager Gandi webhook through Argo CD or Helm, then create the token Secret out-of-band in `cert-manager`.
4. Add a `ClusterIssuer` that references that Secret and issues `*.stationsystems.dev` + `stationsystems.dev` by DNS-01.
5. If Gandi token scoping is too broad for comfort, move authoritative DNS to Cloudflare and use cert-manager's built-in Cloudflare DNS-01 solver with a zone-scoped API token.
