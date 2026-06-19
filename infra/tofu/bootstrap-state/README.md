# Remote-state bucket bootstrap

This is the one small exception to "remote state everywhere": it creates the
remote-state bucket itself. Keep this composition local, small, and rarely used.
The main substrate state in `infra/tofu` can then migrate into the bucket.

Hetzner Object Storage buckets are managed through the S3-compatible MinIO
provider because the `hcloud` provider does not manage Object Storage buckets.

## Inputs

Create Hetzner Object Storage S3 credentials out-of-band, then export them:

```bash
export TF_VAR_object_storage_access_key="..."
export TF_VAR_object_storage_secret_key="..."
```

Set non-secret values in a local `terraform.tfvars` copied from
`terraform.tfvars.example`; do not commit it.

## Apply

```bash
cd infra/tofu/bootstrap-state
tofu init
tofu plan
tofu apply
```

## Migrate the substrate state

After apply, copy the output values into the commented backend block in
`../versions.tf`, then from `infra/tofu` run:

```bash
tofu init -migrate-state
```

Review the prompt before accepting. Then verify:

```bash
tofu state list
```

Do not commit state, `.terraform/`, `.env`, `terraform.tfvars`, or credentials.
