# Create EventBridge Rule
resource "aws_cloudwatch_event_rule" "ecs_deployment_success" {
  name        = var.event_rule_name
  description = "Triggers when ECS service deployment is successful"

  event_pattern = jsonencode({
    "source": ["aws.ecs"],
    "detail-type": ["ECS Service Action"],
    "detail": {
      "clusterArn": [var.ecs_cluster_arn],
      "eventName": ["SERVICE_DEPLOYMENT_COMPLETED"],
      "service": [var.ecs_service_name]
    }
  })
}

# Add Lambda as target for the EventBridge rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.ecs_deployment_success.name
  target_id = "ecsDeploymentNotification"
  arn       = var.lambda_function_arn
}

# Grant EventBridge permission to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_deployment_success.arn
}
