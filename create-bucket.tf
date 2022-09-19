# This script will create a new AWS Simple Storage Solution (S3) bucket as well as create an S3 bucket
# notification to interact with and trigger the corresponding SNS topic to enable S3 Alert Notifications

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

# resource "aws_s3_bucket_notification" "s3_event_bus" {
#   bucket = var.bucket_name
#   lambda_function {
#     id                  = var.bucket_name
#     lambda_function_arn = aws_lambda_function.test_lambda.arn
#     events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
#   }
# }

# resource "aws_lambda_permission" "allow_bucket" {
#   statement_id  = "AllowBucket-${var.bucket_name}"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.test_lambda.arn
#   principal     = "s3.amazonaws.com"
#   source_arn    = "arn:aws:s3:::${var.bucket_name}"
# }

# Create a new S3 Alert Notification for this bucket to add to the SNS Topic
# resource "aws_s3_bucket_notification" "s3_alert_notification" {
#   bucket      = aws_s3_bucket.new_bucket.id
#   eventbridge = true

#   topic {
#     topic_arn = aws_sns_topic.s3_event_sns_topic.arn

#     # Initially only enabling alert notifications for all `ObjectCreated` events, but there are plenty more events to publish,
#     # see: https://docs.aws.amazon.com/AmazonS3/latest/userguide/notification-how-to-event-types-and-destinations.html#supported-notification-event-types
#     events = [
#       "s3:ObjectCreated:*",
#     ]
#   }
# }
