output "main_bucket_name" {
  description = "Name of the main data lake bucket"
  value       = aws_s3_bucket.main.id
}

output "main_bucket_arn" {
  description = "ARN of the main data lake bucket"
  value       = aws_s3_bucket.main.arn
}

output "logging_bucket_name" {
  description = "Name of the access-log and CloudTrail bucket"
  value       = aws_s3_bucket.logging.id
}

output "logging_bucket_arn" {
  description = "ARN of the access-log and CloudTrail bucket"
  value       = aws_s3_bucket.logging.arn
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail audit trail"
  value       = aws_cloudtrail.data_lake_audit.arn
}

output "data_lake_zones" {
  description = "S3 URI for each data lake zone"
  value = {
    raw       = "s3://${aws_s3_bucket.main.id}/raw/"
    processed = "s3://${aws_s3_bucket.main.id}/processed/"
    curated   = "s3://${aws_s3_bucket.main.id}/curated/"
    temp      = "s3://${aws_s3_bucket.main.id}/temp/"
    archive   = "s3://${aws_s3_bucket.main.id}/archive/"
  }
}
