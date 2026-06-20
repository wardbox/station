variable "zone_id" {
  description = "Cloudflare zone ID."
  type        = string
  nullable    = false
}

variable "argo_tailnet_target" {
  description = "Tailscale MagicDNS target for argo.<zone>."
  type        = string
  nullable    = false
}
