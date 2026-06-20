# Vanity DNS for private Argo access. This is intentionally DNS-only and points
# at a Tailscale CGNAT IP; no public Traefik route exists for Argo.
resource "cloudflare_dns_record" "argo_private" {
  zone_id = var.zone_id
  name    = "argo"
  type    = "A"
  content = var.argo_tailnet_ip
  ttl     = 120
  # Required: Cloudflare cannot proxy private Tailscale CGNAT addresses.
  proxied = false
  comment = "Private Argo CD over Tailscale"
}
