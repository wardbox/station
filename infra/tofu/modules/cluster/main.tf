# --------------------------------------------------------------------------
# The k3s cluster: a stable public IP for the control plane, a spread placement
# group, the control-plane node, and N agents. k3s installs itself on first
# boot via cloud-init (user_data) — nothing to run by hand. A final step pulls
# the kubeconfig down to the machine running `tofu apply`.
# --------------------------------------------------------------------------

locals {
  # The control plane sits at a known private address so agents can find it
  # without a chicken-and-egg on IP assignment.
  control_plane_private_ip = cidrhost(var.subnet_cidr, 10)
}

# Shared cluster join secret. Lives only in state — which is why state is
# encrypted and access-controlled.
resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

# A stable public IPv4 for the control plane: known before the server boots, so
# it can go into the API server's TLS SANs and the kubeconfig. Also the natural
# DNS target later.
resource "hcloud_primary_ip" "control_plane_ipv4" {
  name        = "${var.name_prefix}-cp-ipv4"
  type        = "ipv4"
  location    = var.location
  auto_delete = false
}

resource "hcloud_placement_group" "this" {
  name = "${var.name_prefix}-spread"
  type = "spread"
}

resource "hcloud_server" "control_plane" {
  name               = "${var.name_prefix}-cp"
  server_type        = var.control_plane_type
  image              = var.image
  location           = var.location
  ssh_keys           = [var.ssh_key_id]
  placement_group_id = hcloud_placement_group.this.id
  firewall_ids       = [var.firewall_id]
  labels             = { role = "control-plane" }

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.control_plane_ipv4.id
    ipv6_enabled = true
  }

  network {
    network_id = var.network_id
    ip         = local.control_plane_private_ip
  }

  user_data = templatefile("${path.module}/templates/server-init.yaml.tftpl", {
    k3s_version = var.k3s_version
    node_ip     = local.control_plane_private_ip
    public_ip   = hcloud_primary_ip.control_plane_ipv4.ip_address
    k3s_token   = random_password.k3s_token.result
  })
}

resource "hcloud_server" "agent" {
  count = var.agent_count

  name               = "${var.name_prefix}-agent-${count.index + 1}"
  server_type        = var.agent_type
  image              = var.image
  location           = var.location
  ssh_keys           = [var.ssh_key_id]
  placement_group_id = hcloud_placement_group.this.id
  firewall_ids       = [var.firewall_id]
  labels             = { role = "agent" }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = var.network_id
  }

  user_data = templatefile("${path.module}/templates/agent-init.yaml.tftpl", {
    k3s_version = var.k3s_version
    server_ip   = local.control_plane_private_ip
    k3s_token   = random_password.k3s_token.result
  })

  # k3s agents retry joining, so strict ordering isn't required — but starting
  # the server first avoids noisy boot logs.
  depends_on = [hcloud_server.control_plane]
}

# Wait for k3s to be up, then fetch the kubeconfig and point it at the public
# IP. Runs as part of `tofu apply`; writes ./kubeconfig.yaml (gitignored).
resource "terraform_data" "kubeconfig" {
  triggers_replace = [hcloud_server.control_plane.id]

  connection {
    type        = "ssh"
    host        = hcloud_primary_ip.control_plane_ipv4.ip_address
    user        = "root"
    private_key = file(pathexpand(var.ssh_private_key_path))
  }

  # Bounded wait (~5 min) so a failed bootstrap errors clearly instead of
  # hanging forever.
  provisioner "remote-exec" {
    inline = [
      "for i in $(seq 1 60); do test -f /etc/rancher/k3s/k3s.yaml && k3s kubectl get node >/dev/null 2>&1 && exit 0; sleep 5; done; echo 'k3s did not become ready in time' >&2; exit 1",
    ]
  }

  # StrictHostKeyChecking=no + /dev/null known-hosts avoids failures when a
  # recreated node reuses an IP (stale host key). pipefail + test -s make a
  # failed fetch error loudly instead of writing an empty kubeconfig.
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=15 -i '${pathexpand(var.ssh_private_key_path)}' root@${hcloud_primary_ip.control_plane_ipv4.ip_address} 'cat /etc/rancher/k3s/k3s.yaml' \
        | sed 's#https://127.0.0.1:6443#https://${hcloud_primary_ip.control_plane_ipv4.ip_address}:6443#' \
        > '${path.root}/kubeconfig.yaml'
      chmod 600 '${path.root}/kubeconfig.yaml'
      test -s '${path.root}/kubeconfig.yaml'
    EOT
  }
}
