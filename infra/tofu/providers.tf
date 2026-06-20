# --------------------------------------------------------------------------
# Providers. The hcloud token is read from the HCLOUD_TOKEN environment
# variable (see .env.example) — deliberately not a variable, so it never lands
# in tfvars or state inputs.
# --------------------------------------------------------------------------
provider "hcloud" {
  # token = sourced from $HCLOUD_TOKEN
}

provider "random" {}

# Reads token from CLOUDFLARE_API_TOKEN. Do not put DNS credentials in tfvars.
provider "cloudflare" {}
