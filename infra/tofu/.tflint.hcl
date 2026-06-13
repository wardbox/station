plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "hcloud" {
  enabled = true
  version = "0.2.0"
  source  = "github.com/hetznercloud/tflint-ruleset-hcloud"
}
