# SNS Topic
resource "aws_sns_topic" "notification_topic" {
  name = var.topic_name
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol  = "email"
  endpoint  = var.email_address
}
