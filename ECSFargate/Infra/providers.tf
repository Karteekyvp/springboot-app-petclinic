terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "your-terraform-MeghanaKarteek061122110203"  # Will be created in s3_backend module
    key            = "ecs-fargate/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"          # Created in s3_backend module
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
