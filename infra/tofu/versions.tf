# --------------------------------------------------------------------------
# Tofu + provider version constraints and remote state backend.
# --------------------------------------------------------------------------
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.65"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Remote state in Hetzner Object Storage. The bucket is bootstrapped by
  # infra/tofu/bootstrap-state, then this substrate state is migrated into it.
  # Native S3 locking via use_lockfile (OpenTofu 1.10+) means no DynamoDB. Backend
  # creds come from AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY in the environment.
  #
  backend "s3" {
    bucket                      = "station-tofu-state"
    key                         = "substrate/terraform.tfstate"
    region                      = "us-east-1" # nominal; Hetzner ignores it
    # Hetzner's real S3-compatible endpoint for the FSN1 Object Storage region.
    endpoints                   = { s3 = "https://fsn1.your-objectstorage.com" }
    use_lockfile                = true # native locking, no DynamoDB
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true # Hetzner doesn't support the checksum header
  }
}
