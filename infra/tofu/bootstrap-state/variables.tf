variable "bucket_name" {
  description = "Globally unique Hetzner Object Storage bucket name for the substrate OpenTofu state."
  type        = string
  default     = "station-tofu-state"
  nullable    = false
}

variable "object_storage_region" {
  description = "Hetzner Object Storage region. Object Storage is currently EU-only."
  type        = string
  default     = "fsn1"
  nullable    = false

  validation {
    condition     = contains(["fsn1", "nbg1", "hel1"], var.object_storage_region)
    error_message = "Use one of Hetzner's Object Storage regions: fsn1, nbg1, hel1."
  }
}

variable "object_storage_server" {
  description = "Hetzner Object Storage S3 API host, without scheme."
  type        = string
  default     = "fsn1.your-objectstorage.com"
  nullable    = false
}

variable "object_storage_access_key" {
  description = "Hetzner Object Storage access key. Pass with TF_VAR_object_storage_access_key; do not commit."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "object_storage_secret_key" {
  description = "Hetzner Object Storage secret key. Pass with TF_VAR_object_storage_secret_key; do not commit."
  type        = string
  sensitive   = true
  nullable    = false
}
