# Dedicated logging bucket — separating audit logs from data prevents log pollution and makes
# compliance evidence easy to export: "here is every access log, nothing else".
resource "aws_s3_bucket" "logging" {
  bucket = local.log_bucket
  tags   = merge(local.tags, { Purpose = "AuditLogs" })
}

resource "aws_s3_bucket_ownership_controls" "logging" {
  bucket = aws_s3_bucket.logging.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket = aws_s3_bucket.logging.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Combined policy granting write access to both the S3 log delivery service (server access
# logs) and CloudTrail (API audit trail). Both services write to the same bucket but
# different prefixes, keeping them easy to query separately.
resource "aws_s3_bucket_policy" "logging" {
  bucket = aws_s3_bucket.logging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3AccessLogDelivery"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${local.log_bucket}/s3-access-logs/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${local.bucket_name}"
          }
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      },
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${local.log_bucket}"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${local.account_id}:trail/data-lake-audit-trail"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${local.log_bucket}/AWSLogs/${local.account_id}/*"
        # s3:x-amz-acl condition omitted: BucketOwnerEnforced rejects ACL headers, and
        # CloudTrail no longer requires the bucket-owner-full-control ACL (Nov 2023 update).
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.aws_region}:${local.account_id}:trail/data-lake-audit-trail"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.logging]
}
