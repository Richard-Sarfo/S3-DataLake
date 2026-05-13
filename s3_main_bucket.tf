# Main data lake bucket — houses raw, processed, curated, temp, and archive zones.
resource "aws_s3_bucket" "main" {
  bucket = local.bucket_name
  tags   = local.tags
}

# ACLs disabled — modern best practice; permissions are managed via bucket policy and IAM.
resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access — data lake must never be publicly readable.
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SSE-S3 with bucket key — satisfies GDPR/HIPAA encryption-at-rest requirement at no extra cost.
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Versioning — allows recovery from accidental deletion or overwrite without external backups.
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Access logging — records every S3 API call (who, what, when) to the dedicated log bucket.
resource "aws_s3_bucket_logging" "main" {
  bucket        = aws_s3_bucket.main.id
  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "s3-access-logs/"

  depends_on = [aws_s3_bucket_policy.logging]
}
