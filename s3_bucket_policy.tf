# Bucket policy on the main data lake bucket enforces four controls:
#   1. EnforceSSLOnly       — reject any request that arrives over plain HTTP
#   2. DenyUnencryptedUploads — reject PutObject without AES256 header (belt-and-suspenders
#                               alongside default bucket encryption)
#   3-5. Role Allow statements — DataEngineerRole, GlueServiceRole, RedshiftIAMRole are the
#                                only identities that need bucket access; everything else is
#                                implicitly denied by the absence of an Allow.
#
# Folders are created before this policy so the deny conditions don't block Terraform's own
# PutObject calls for the placeholder objects.
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceSSLOnly"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "DenyUnencryptedObjectUploads"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${local.bucket_name}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      },
      {
        Sid    = "AllowDataEngineerRole"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_iam_role.data_engineer.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      },
      {
        Sid    = "AllowGlueServiceRole"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_iam_role.glue_service.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      },
      {
        Sid    = "AllowRedshiftRole"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_iam_role.redshift.arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      }
    ]
  })

  # Apply after folders so Terraform's own PutObject calls succeed before the deny kicks in.
  depends_on = [
    aws_s3_object.raw,
    aws_s3_object.processed,
    aws_s3_object.curated,
    aws_s3_object.temp,
    aws_s3_object.archive,
    aws_s3_bucket_public_access_block.main,
  ]
}
