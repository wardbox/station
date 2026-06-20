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

variable "location" {
  description = "Hetzner location. hil = Hillsboro OR; ash = Ashburn VA. (Replaces the deprecated datacenter attribute.)"
  type        = string
  default     = "hil"
  nullable    = false

  validation {
    condition     = contains(["hil", "ash"], var.location)
    error_message = "Use a US location: hil (Hillsboro) or ash (Ashburn)."
  }
}

variable "network_zone" {
  description = "Hetzner network zone, must match the location (us-west for hil, us-east for ash)."
  type        = string
  default     = "us-west"
  nullable    = false

  validation {
    condition     = (var.location == "hil" && var.network_zone == "us-west") || (var.location == "ash" && var.network_zone == "us-east")
    error_message = "network_zone must match location: hil requires us-west; ash requires us-east."
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
  description = "Server type for the control-plane node. US locations (hil/ash) are x86-only: use cpx*. cax* (arm64) is EU-only."
  type        = string
  default     = "cpx21"
  nullable    = false
}

variable "agent_type" {
  description = "Server type for agent nodes. US = cpx* (x86)."
  type        = string
  default     = "cpx21"
  nullable    = false
}

variable "agent_count" {
  description = "Number of agent (worker) nodes. 0 is valid — the control plane schedules workloads too, so a single node runs the blog."
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

  validation {
    condition     = can(cidrhost(var.network_cidr, 0)) && can(regex("\\.", cidrhost(var.network_cidr, 0)))
    error_message = "network_cidr must be a valid IPv4 CIDR (e.g. 10.0.0.0/16)."
  }
}

variable "subnet_cidr" {
  description = "Private subnet range (must sit within network_cidr). The control plane takes .10."
  type        = string
  default     = "10.0.1.0/24"
  nullable    = false

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0)) && can(regex("\\.", cidrhost(var.subnet_cidr, 0)))
    error_message = "subnet_cidr must be a valid IPv4 CIDR (e.g. 10.0.1.0/24)."
  }
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
    condition     = length(var.admin_cidrs) > 0 && alltrue([for c in var.admin_cidrs : can(cidrhost(c, 0))])
    error_message = "Set at least one valid admin CIDR (e.g. [\"203.0.113.7/32\"]). Find yours: curl -s ifconfig.me"
  }
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for stationsystems.dev. Provider token comes from CLOUDFLARE_API_TOKEN."
  type        = string
  default     = "9a24900325685100ac2892c16c770c7b"
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-f]{32}$", var.cloudflare_zone_id))
    error_message = "cloudflare_zone_id must be a 32-character lowercase hexadecimal Cloudflare zone ID."
  }
}

variable "argo_tailnet_ip" {
  description = "Tailscale IP for the private Argo CD vanity A record."
  type        = string
  default     = "100.98.174.23"
  nullable    = false

  validation {
    condition     = can(cidrhost("${var.argo_tailnet_ip}/32", 0)) && cidrcontains("100.64.0.0/10", var.argo_tailnet_ip)
    error_message = "argo_tailnet_ip must be a valid Tailscale IPv4 address in 100.64.0.0/10."
  }
}
