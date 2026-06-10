variable "name_prefix" {
  description = "Prefix for named resources."
  type        = string
  nullable    = false
}

variable "datacenter" {
  description = "Hetzner datacenter (e.g. hil-dc1)."
  type        = string
  nullable    = false
}

variable "image" {
  description = "Base OS image for all nodes."
  type        = string
  nullable    = false
}

variable "k3s_version" {
  description = "Pinned k3s version (INSTALL_K3S_VERSION format)."
  type        = string
  nullable    = false
}

variable "control_plane_type" {
  description = "Server type for the control-plane node."
  type        = string
  nullable    = false
}

variable "agent_type" {
  description = "Server type for agent nodes."
  type        = string
  nullable    = false
}

variable "agent_count" {
  description = "Number of agent nodes."
  type        = number
  nullable    = false
}

variable "network_id" {
  description = "ID of the private network to attach nodes to."
  type        = string
  nullable    = false
}

variable "subnet_cidr" {
  description = "Private subnet range; the control plane takes host .10."
  type        = string
  nullable    = false
}

variable "firewall_id" {
  description = "ID of the firewall to apply to every node."
  type        = string
  nullable    = false
}

variable "ssh_key_id" {
  description = "ID of the SSH key authorized on every node."
  type        = string
  nullable    = false
}

variable "ssh_private_key_path" {
  description = "Local path to the SSH private key, used to fetch the kubeconfig."
  type        = string
  nullable    = false
}
