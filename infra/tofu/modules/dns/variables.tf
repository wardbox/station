variable "zone_id" {
  description = "Cloudflare zone ID."
  type        = string
  nullable    = false
}

variable "argo_tailnet_ip" {
  description = "Tailscale IP for argo.<zone>."
  type        = string
  nullable    = false
}
