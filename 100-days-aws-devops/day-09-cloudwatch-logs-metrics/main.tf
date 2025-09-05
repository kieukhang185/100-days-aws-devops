terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  default     = "dev-100days-mfa"
  description = "The AWS profile to use for authentication"
}

variable "instance_id" {
  description = "The ID of the EC2 instance to monitor"
  type        = string
}

resource "aws_cloudwatch_log_group" "day009" {
  name              = "/aws/100-days-aws-devops/day-09"
  retention_in_days = 7
  tags = {
    Project     = "100-days-aws-devops"
    Day         = "09"
    Environment = "dev"
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "day009-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors EC2 CPU utilization when CPU > 70% for 5 min"
  dimensions = {
    InstanceId = var.instance_id
  }
  tags = {
    Project     = "100-days-aws-devops"
    Day         = "09"
    Environment = "dev"
  }
}

resource "aws_cloudwatch_dashboard" "day009" {
  dashboard_name = "day009-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 6
        height = 6
        properties = {
          metrics = [["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id]]
          period  = 300
          stat    = "Average"
          region  = var.aws_region
          title   = "EC2 Instance CPU Utilization"
        }
      }
    ]
  })
}
