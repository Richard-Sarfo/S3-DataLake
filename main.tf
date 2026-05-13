terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  bucket_name = "data-lake-prod-${data.aws_caller_identity.current.account_id}"
  log_bucket  = "data-lake-prod-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Environment = "Production"
    Owner       = "DataEngineering"
    Purpose     = "DataLake"
    CostCenter  = "Analytics"
  }
}
