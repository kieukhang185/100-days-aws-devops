
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.12"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type        = string
  default     = "dev-100days-mfa"
  description = "The AWS profile to use for authentication"
}


provider "aws" {
  region  = var.region
  profile = var.aws_profile
}


variable "alert_email" {
  type = string
}

resource "aws_budgets_budget" "monthly_cost" {
  name              = "Monthly-Cost-Guardrail"
  budget_type       = "COST"
  limit_amount      = "30"
  limit_unit        = "USD"
  time_period_start = formatdate("YYYY-MM-DD", timestamp())
  time_unit         = "MONTHLY"
  cost_types {
    include_credit             = true
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = true
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_blended                = false
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 5
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 15
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  tags = {
    Project     = "aws-devops-100-days"
    Day         = "003"
    Environment = "dev"
  }
}
