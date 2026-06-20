variable "zone_id" {
  description = "Cloudflare zone ID."
  type        = string
  nullable    = false
}

variable "argo_tailnet_ip" {
  description = "Tailscale IP for argo.<zone>."
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrhost("${var.argo_tailnet_ip}/32", 0)) && cidrcontains("100.64.0.0/10", var.argo_tailnet_ip)
    error_message = "argo_tailnet_ip must be a valid Tailscale IPv4 address in 100.64.0.0/10."
  }
}
