# --------------------------------------------------------------------------
# One private network + subnet, and a single firewall fronting every node.
# Hetzner firewalls filter the public interface only; intra-cluster traffic on
# the private network is unfiltered, so no internal allow-rules are needed.
# --------------------------------------------------------------------------

resource "hcloud_network" "this" {
  name     = "${var.name_prefix}-net"
  ip_range = var.network_cidr
}

resource "hcloud_network_subnet" "this" {
  network_id   = hcloud_network.this.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.subnet_cidr
}

resource "hcloud_firewall" "this" {
  name = "${var.name_prefix}-fw"

  rule {
    description = "SSH (admin only)"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = var.admin_cidrs
  }

  rule {
    description = "k3s API (admin only)"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = var.admin_cidrs
  }

  rule {
    description = "HTTP (public ingress)"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "HTTPS (public ingress)"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "ICMP (ping)"
    direction   = "in"
    protocol    = "icmp"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }
}
