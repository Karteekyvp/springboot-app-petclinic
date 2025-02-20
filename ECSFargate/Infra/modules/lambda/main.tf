# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Attach Basic Lambda Execution and SNS Publish Policies
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "sns_publish_policy" {
  name = "sns-publish-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "sns:Publish",
      Resource = var.sns_topic_arn
    }]
  })
}

# Package Lambda Function Code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda Function Resource
resource "aws_lambda_function" "notification_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = data.archive_file.lambda_zip.output_path

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_execution,
    aws_iam_role_policy.sns_publish_policy
  ]
}
