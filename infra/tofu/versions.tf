# --------------------------------------------------------------------------
# Tofu + provider version constraints, and (later) the remote state backend.
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

  # Remote state in Hetzner Object Storage. It's EU-only (FSN1/NBG1/HEL1) — that's
  # fine, state has no latency needs even with the cluster in the US. Native S3
  # locking via use_lockfile (OpenTofu 1.10+) means no DynamoDB. Creds come from
  # AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY in the environment (see .env.example).
  #
  # One-time setup, then uncomment and run `tofu init`:
  #   1. Hetzner console -> Object Storage -> create bucket (e.g. station-tofu-state) in FSN1
  #   2. create S3 credentials (access key + secret); put them in .env
  #
  # backend "s3" {
  #   bucket                      = "station-tofu-state"
  #   key                         = "substrate/terraform.tfstate"
  #   region                      = "us-east-1"            # nominal; Hetzner ignores it
  #   endpoints                   = { s3 = "https://fsn1.your-objectstorage.com" }
  #   use_lockfile                = true                   # native locking, no DynamoDB
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  #   skip_requesting_account_id  = true
  #   skip_metadata_api_check     = true
  #   skip_s3_checksum            = true                   # Hetzner doesn't support the checksum header
  # }
}
