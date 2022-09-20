output "aws_sns_topic_arn" {
  value       = aws_sns_topic.s3_event_sns_topic.arn
  description = "The Amazon Resource Name (ARN) for the SNS Topic binded to the S3 bucket"
}

output "bucket_name" {
  value       = var.bucket_name
  description = "The name of the created S3 bucket"
}

output "sns_notifications_email_address" {
  value       = var.sns_email_address
  description = "The email address used to subscribe to the S3 Alert Notifications SNS Topic"
}
