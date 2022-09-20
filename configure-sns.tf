# This script will create a new Amazon CloudWatch/EventBridge Event and Rule to capture event data specified in the `event_pattern`,
# format it to be easily readable, and publish the event to a newly created AWS Simple Notification Service (SNS) Topic

# Creating an AWS EventBridge Event Rule to capture any S3 object creation events
resource "aws_cloudwatch_event_rule" "s3_alert_notifications_rule" {
  name          = "capture-aws-s3-object-creation"
  description   = "Capture each S3 object creation event"
  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"]
}
EOF
}

# Creating an AWS EventBridge Event Target to target the S3 SNS Topic with the S3 rule
resource "aws_cloudwatch_event_target" "s3_alert_notifications_target" {
  arn       = aws_sns_topic.s3_event_sns_topic.arn
  rule      = aws_cloudwatch_event_rule.s3_alert_notifications_rule.name
  target_id = "SendtoSNS"
  input_transformer {
    input_paths = {
      timestamp = "$.time",
      bucket    = "$.detail.bucket.name",
      object    = "$.detail.object.key",
      requester = "$.detail.requester"
    }
    input_template = "\"A new object named '<object>' has been created in the '<bucket>' S3 bucket by AWS account '<requester>' at '<timestamp>'\""
  }
}

# Creating an AWS SNS Topic for any "Object Created" S3 Alert Notifications
resource "aws_sns_topic" "s3_event_sns_topic" {
  name = "s3-alert-notifications"
}

# Creating the SNS Topic IAM Policy to enable publishing to SNS
resource "aws_sns_topic_policy" "sns_topic_iam_policy" {
  arn    = aws_sns_topic.s3_event_sns_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_iam_policy_document.json
}

data "aws_iam_policy_document" "sns_topic_iam_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.s3_event_sns_topic.arn]
  }
}

# Configuring an SNS Topic Subscription to send an email to a specified email address when a new event is published
resource "aws_sns_topic_subscription" "s3_bucket_event_notification_target" {
  topic_arn = aws_sns_topic.s3_event_sns_topic.arn
  protocol  = "email"
  endpoint  = var.sns_email_address
}
