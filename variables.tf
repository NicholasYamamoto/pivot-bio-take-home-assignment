variable "bucket_name" {
  type        = string
  description = "The name given to the created S3 bucket"
}

variable "sns_email_address" {
  type        = string
  description = "The email address used to send S3 Event Notifications to via SNS and Lambda"
}
