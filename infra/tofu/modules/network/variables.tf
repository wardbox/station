variable "name_prefix" {
  description = "Prefix for named resources."
  type        = string
  nullable    = false
}

variable "network_cidr" {
  description = "Private network range."
  type        = string
  nullable    = false
}

variable "subnet_cidr" {
  description = "Private subnet range within network_cidr."
  type        = string
  nullable    = false
}

variable "network_zone" {
  description = "Hetzner network zone (us-west / us-east)."
  type        = string
  nullable    = false
}

variable "admin_cidrs" {
  description = "Source CIDRs allowed to reach SSH (22) and the k3s API (6443)."
  type        = list(string)
  nullable    = false
}
