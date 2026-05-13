# S3 has no real directories — a zero-byte object with a trailing "/" is the convention for
# creating a visible "folder" in the console and making prefix-based IAM conditions work.
# SSE is specified explicitly so Terraform's own PutObject calls pass the encryption header
# even before the bucket policy deny is in place.

resource "aws_s3_object" "raw" {
  bucket                 = aws_s3_bucket.main.id
  key                    = "raw/"
  content                = ""
  server_side_encryption = "AES256"

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.main]
}

resource "aws_s3_object" "processed" {
  bucket                 = aws_s3_bucket.main.id
  key                    = "processed/"
  content                = ""
  server_side_encryption = "AES256"

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.main]
}

resource "aws_s3_object" "curated" {
  bucket                 = aws_s3_bucket.main.id
  key                    = "curated/"
  content                = ""
  server_side_encryption = "AES256"

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.main]
}

resource "aws_s3_object" "temp" {
  bucket                 = aws_s3_bucket.main.id
  key                    = "temp/"
  content                = ""
  server_side_encryption = "AES256"

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.main]
}

resource "aws_s3_object" "archive" {
  bucket                 = aws_s3_bucket.main.id
  key                    = "archive/"
  content                = ""
  server_side_encryption = "AES256"

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.main]
}
