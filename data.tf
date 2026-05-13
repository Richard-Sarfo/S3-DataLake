data "aws_caller_identity" "current" {}

# Look up IAM roles created in Lab 1.1 so the bucket policy can reference their ARNs.
data "aws_iam_role" "data_engineer" {
  name = "DataEngineerRole"
}

data "aws_iam_role" "glue_service" {
  name = "GlueServiceRole"
}

data "aws_iam_role" "redshift" {
  name = "RedshiftIAMRole"
}
