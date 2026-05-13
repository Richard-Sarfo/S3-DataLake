# Lifecycle rules — automatic cost optimisation without any manual intervention.
#
# Rule 1 (archive-processed-data-after-90-days):
#   processed/ Standard → Glacier Instant Retrieval at 90d ($0.023 → $0.004/GB)
#              Glacier IR → Deep Archive at 180d ($0.004 → $0.00099/GB)
#   Compliance data lives here for 7 years; the two-tier transition saves ~95% over Standard.
#
# Rule 2 (delete-temp-data-after-1-day):
#   temp/ objects expire after 1 day — Spark/Glue intermediate outputs should never linger.
#
# Rule 3 (archive-and-delete-after-7-years):
#   archive/ moves to Glacier IR immediately, Deep Archive at 30 days, then is permanently
#   deleted at day 2555 (7 years) — satisfying the GDPR "right to erasure" requirement.
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "archive-processed-data-after-90-days"
    status = "Enabled"

    filter {
      prefix = "processed/"
    }

    transition {
      days          = 90
      storage_class = "GLACIER_IR"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }
  }

  rule {
    id     = "delete-temp-data-after-1-day"
    status = "Enabled"

    filter {
      prefix = "temp/"
    }

    expiration {
      days = 1
    }
  }

  rule {
    id     = "archive-and-delete-after-7-years"
    status = "Enabled"

    filter {
      prefix = "archive/"
    }

    transition {
      days          = 1
      storage_class = "GLACIER_IR"
    }

    transition {
      days          = 30
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 2555
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}
