variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use (omit if not using profiles)"
  type        = string
  default     = "default"
}

variable "name_prefix" {
  description = "Name prefix for created resources"
  type        = string
  default     = "day001-ec2-ssm"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "extra_tags" {
  description = "Additional tags to add to all resources"
  type        = map(string)
  default     = {}
}
