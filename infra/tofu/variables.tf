# --------------------------------------------------------------------------
# Composition inputs. Defaults are the "start small" opening position from the
# build spec; override in terraform.tfvars.
# --------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for all named Hetzner resources."
  type        = string
  default     = "station"
  nullable    = false
}

variable "datacenter" {
  description = "Hetzner datacenter. hil-dc1 = Hillsboro OR; ash-dc1 = Ashburn VA."
  type        = string
  default     = "hil-dc1"
  nullable    = false

  validation {
    condition     = contains(["hil-dc1", "ash-dc1"], var.datacenter)
    error_message = "Use a US datacenter: hil-dc1 (Hillsboro) or ash-dc1 (Ashburn)."
  }
}

variable "network_zone" {
  description = "Hetzner network zone, must match the datacenter (us-west for hil, us-east for ash)."
  type        = string
  default     = "us-west"
  nullable    = false

  validation {
    condition     = contains(["us-west", "us-east"], var.network_zone)
    error_message = "Use us-west (Hillsboro) or us-east (Ashburn)."
  }
}

variable "image" {
  description = "Base OS image for all nodes."
  type        = string
  default     = "ubuntu-24.04"
  nullable    = false
}

variable "k3s_version" {
  description = "Pinned k3s version (INSTALL_K3S_VERSION format). Pin for reproducibility; bump deliberately."
  type        = string
  default     = "v1.35.5+k3s1"
  nullable    = false
}

variable "control_plane_type" {
  description = "Server type for the control-plane node (cax* = arm64, cpx*/cx* = amd64)."
  type        = string
  default     = "cax11"
  nullable    = false
}

variable "agent_type" {
  description = "Server type for agent nodes."
  type        = string
  default     = "cax21"
  nullable    = false
}

variable "agent_count" {
  description = "Number of agent (worker) nodes."
  type        = number
  default     = 1
  nullable    = false

  validation {
    condition     = var.agent_count >= 0 && var.agent_count <= 10
    error_message = "agent_count must be between 0 and 10."
  }
}

variable "network_cidr" {
  description = "Private network range."
  type        = string
  default     = "10.0.0.0/16"
  nullable    = false
}

variable "subnet_cidr" {
  description = "Private subnet range (must sit within network_cidr). The control plane takes .10."
  type        = string
  default     = "10.0.1.0/24"
  nullable    = false
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key authorized on every node."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  nullable    = false
}

variable "ssh_private_key_path" {
  description = "Path to the matching SSH private key, used to fetch the kubeconfig after the cluster boots."
  type        = string
  default     = "~/.ssh/id_ed25519"
  nullable    = false
}

variable "admin_cidrs" {
  description = "Source CIDRs allowed to reach SSH (22) and the k3s API (6443). Use your IP/32."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.admin_cidrs) > 0
    error_message = "Set at least one admin CIDR (e.g. [\"203.0.113.7/32\"]). Find yours: curl -s ifconfig.me"
  }
}
