# CloudTrail captures every AWS API call against the account — bucket creation, policy
# changes, deletions — complementing S3 server access logs which only cover object-level
# operations.  Together they answer:
#   S3 access logs → "who downloaded file X at time T?"
#   CloudTrail     → "who deleted the bucket / changed the policy?"
resource "aws_cloudtrail" "data_lake_audit" {
  name                          = "data-lake-audit-trail"
  s3_bucket_name                = aws_s3_bucket.logging.id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    # Log all S3 object-level operations (GetObject, PutObject, DeleteObject …).
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }

  tags = local.tags

  # Logging bucket policy must exist before CloudTrail tries to write to it.
  depends_on = [aws_s3_bucket_policy.logging]
}
