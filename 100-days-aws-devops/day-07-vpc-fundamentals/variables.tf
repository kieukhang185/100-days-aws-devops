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
