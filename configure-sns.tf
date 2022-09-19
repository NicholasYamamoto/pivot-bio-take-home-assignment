# This script will create a new AWS Simple Notification Service (SNS) topic and configure it to
# publish any events under the `aws_s3_bucket_notification.s3_alert_notification.topic.events` block

# Creating an AWS Key Management Service (KMS) key used to encrypt/decrypt the published SNS message
resource "aws_kms_key" "sns_topic_encryption_decryption_key" {
  description = "Key used to encrypt/decrypt published messages sent to/from SNS"
  policy      = data.aws_iam_policy_document.topic_key_kms_policy.json
}

# Creating an AWS Identity Access Management (IAM) Policy to allow root user to administer the key
# and allow the S3 bucket to use it
data "aws_iam_policy_document" "topic_key_kms_policy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [aws_s3_bucket.new_bucket.arn]
  }
  # Allow the root user to administer the topic_key
  statement {
    effect = "Allow"
    principals {
      # Might have to update the account_id here
      identifiers = ["arn:aws:iam::654577565718:root"]
      type        = "AWS"
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

# Creating an alias for the SNS Topic Key
resource "aws_kms_alias" "sns_topic_key_alias" {
  name          = "alias/sns-topic-key"
  target_key_id = aws_kms_key.sns_topic_encryption_decryption_key.key_id
}

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
  rule      = aws_cloudwatch_event_rule.s3_alert_notifications_rule.name
  target_id = "SendtoSNS"
  arn       = aws_sns_topic.s3_event_sns_topic.arn
}

# Creating an AWS SNS Topic for any "Object Created" S3 Alert Notifications
resource "aws_sns_topic" "s3_event_sns_topic" {
  name              = "s3-alert-notifications"
  kms_master_key_id = aws_kms_alias.sns_topic_key_alias.name
}

# Creating the SNS Topic IAM Policy to enable publishing to SNS
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.s3_event_sns_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
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
# ss
# resource "aws_sns_topic_policy" "send_event_to_sns" {
#   arn    = aws_sns_topic.s3_event_sns_topic.arn
#   policy = <<POLICY
#   {
#   	"Version": "2012-10-17",
#   	"Statement": [{
#   		"Effect": "Allow",
#   		"Principal": {
#   			"AWS": "*",
#   			"Service": "events.amazonaws.com"
#   		},
#   		"Action": [
#   			"sns:Publish",
#   			"SNS:GetTopicAttributes",
#   			"SNS:SetTopicAttributes",
#   			"SNS:AddPermission",
#   			"SNS:RemovePermission",
#   			"SNS:DeleteTopic",
#   			"SNS:Subscribe",
#   			"SNS:ListSubscriptionsByTopic",
#   			"SNS:Publish",
#   			"SNS:Receive"
#   		],
#   		"Resource": "${aws_sns_topic.s3_event_sns_topic.arn}",
#   		"Condition": {
#   			"ArnLike": {
#   				"aws:SourceArn": "${aws_s3_bucket.new_bucket.arn}"
#   			},
#   			"StringEquals": {
#   				"aws:SourceOwner": "654577565718"
#   			}
#   		}
#   	}]
#   }
#   POLICY
# }

# Configuring a SNS Topic Subscription to send an email to a specified email address when a new event is published
resource "aws_sns_topic_subscription" "s3_bucket_event_notification_target" {
  topic_arn = aws_sns_topic.s3_event_sns_topic.arn
  protocol  = "email"
  endpoint  = var.sns_email_address
}


# resource "aws_iam_role" "iam_for_lambda" {
#   name = "iam_for_lambda"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#   		"Action": [
#   			"sts:AssumeRole"
#   		],
#         "Principal": {
#           "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# data "aws_iam_policy_document" "lambda" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents"
#     ]
#     resources = ["arn:aws:logs:*:*:*"]
#   }
#   statement {
#     effect    = "Allow"
#     actions   = ["sns:Publish"]
#     resources = [aws_sns_topic.s3_event_sns_topic.arn]
#   }
# }

# resource "aws_iam_role_policy" "lambda" {
#   role   = aws_iam_role.iam_for_lambda.id
#   policy = data.aws_iam_policy_document.lambda.json
# }

# resource "aws_lambda_function" "test_lambda" {
#   # If the file is not in the current working directory you will need to include a
#   # path.module in the filename.
#   filename                       = "lambda_mailer.py"
#   function_name                  = "lambda_handler"
#   role                           = aws_iam_role.iam_for_lambda.arn
#   handler                        = "lambda_mailer.handler"
#   source_code_hash               = filebase64sha256("lambda_mailer.py")
#   memory_size                    = 128
#   reserved_concurrent_executions = 10
#   runtime                        = "python3.6"
#   publish                        = true
# }
