
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region to deploy resources"
}

variable "aws_profile" {
  type        = string
  default     = "dev-100days-mfa"
  description = "The AWS profile to use for authentication"
}
