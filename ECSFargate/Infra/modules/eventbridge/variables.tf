variable "event_rule_name" {
  description = "Name of the EventBridge rule"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to trigger"
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ARN of the ECS cluster to monitor"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service to monitor"
  type        = string
}
