# --------------------------------------------------------------------------
# The substrate composition: an SSH key, a private network + firewall, and a
# k3s cluster on top. `tofu apply` stands the whole thing up and writes a
# kubeconfig locally. Tofu stops here ("the cluster exists"); Argo owns the
# inside of the cluster (build-spec layer 2).
# --------------------------------------------------------------------------

resource "hcloud_ssh_key" "admin" {
  name       = "${var.name_prefix}-admin"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

module "network" {
  source = "./modules/network"

  name_prefix  = var.name_prefix
  network_cidr = var.network_cidr
  subnet_cidr  = var.subnet_cidr
  network_zone = var.network_zone
  admin_cidrs  = var.admin_cidrs
}

module "cluster" {
  source = "./modules/cluster"

  name_prefix          = var.name_prefix
  datacenter           = var.datacenter
  image                = var.image
  k3s_version          = var.k3s_version
  control_plane_type   = var.control_plane_type
  agent_type           = var.agent_type
  agent_count          = var.agent_count
  network_id           = module.network.network_id
  subnet_cidr          = var.subnet_cidr
  firewall_id          = module.network.firewall_id
  ssh_key_id           = hcloud_ssh_key.admin.id
  ssh_private_key_path = var.ssh_private_key_path

  # The subnet must exist before a server can attach a private IP in it.
  depends_on = [module.network]
}
