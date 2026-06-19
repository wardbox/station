provider "minio" {
  minio_server   = var.object_storage_server
  minio_user     = var.object_storage_access_key
  minio_password = var.object_storage_secret_key
  minio_region   = var.object_storage_region
  minio_ssl      = true
}
