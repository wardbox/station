resource "minio_s3_bucket" "state" {
  bucket         = var.bucket_name
  acl            = "private"
  object_locking = false
}

resource "minio_s3_bucket_versioning" "state" {
  bucket = minio_s3_bucket.state.bucket

  versioning_configuration {
    status = "Enabled"
  }
}
