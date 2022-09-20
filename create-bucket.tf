# This script will create a new AWS Simple Storage Solution (S3) bucket, configures it to use Server-Side Encryption (SSE),
# and finally enable it to use Amazon EventBridge to trigger the custom Event Rule and publish messages to SNS

# Create a new KMS key to encrypt S3 bucket objects
resource "aws_kms_key" "s3_bucket_object_encryption_key" {
  description             = "Key used to encrypt S3 bucket objects"
  deletion_window_in_days = 10
}

# Create a new AWS S3 bucket
resource "aws_s3_bucket" "new_bucket" {
  bucket = var.bucket_name
}

# Configure Server-Side Encryption to harden security around the S3 bucket
# More details on enabling SSE for S3 can be found here:
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingServerSideEncryption.html
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse_config" {
  bucket = aws_s3_bucket.new_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_bucket_object_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Enabling Amazon EventBridge for the created bucket to trigger the Event Rule
resource "aws_s3_bucket_notification" "s3_alert_notification" {
  bucket      = aws_s3_bucket.new_bucket.id
  eventbridge = true
}
