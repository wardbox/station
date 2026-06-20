# Vanity DNS for private Argo access. This is intentionally DNS-only and points
# at Tailscale MagicDNS; no public Traefik route exists for Argo.
resource "cloudflare_dns_record" "argo_private" {
  zone_id = var.zone_id
  name    = "argo"
  type    = "CNAME"
  content = var.argo_tailnet_target
  ttl     = 120
  # Required: Cloudflare cannot proxy this external Tailscale MagicDNS target.
  proxied = false
  comment = "Private Argo CD over Tailscale MagicDNS"
}
