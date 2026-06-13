variable "name_prefix" {
  description = "Prefix for named resources."
  type        = string
  nullable    = false
}

variable "network_cidr" {
  description = "Private network range."
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrhost(var.network_cidr, 0))
    error_message = "network_cidr must be a valid IPv4 CIDR (e.g. 10.0.0.0/16)."
  }
}

variable "subnet_cidr" {
  description = "Private subnet range within network_cidr."
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid IPv4 CIDR (e.g. 10.0.1.0/24)."
  }
}

variable "network_zone" {
  description = "Hetzner network zone (us-west / us-east)."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["us-west", "us-east"], var.network_zone)
    error_message = "network_zone must be one of: us-west, us-east."
  }
}

variable "admin_cidrs" {
  description = "Source CIDRs allowed to reach SSH (22) and the k3s API (6443)."
  type        = list(string)
  nullable    = false

  validation {
    condition     = alltrue([for c in var.admin_cidrs : can(cidrhost(c, 0))])
    error_message = "admin_cidrs entries must be valid IPv4 CIDRs."
  }
}
