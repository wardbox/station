output "bucket_name" {
  description = "State bucket name."
  value       = minio_s3_bucket.state.bucket
}

output "backend_endpoint" {
  description = "Endpoint URL to use in the root s3 backend block."
  value       = "https://${var.object_storage_server}"
}

output "backend_region" {
  description = "Object Storage region used for the bucket."
  value       = var.object_storage_region
}
