terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.12"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_s3_bucket" "example" {
  bucket = "day004-tagging-demo"

  tags = {
    Project     = "aws-devops-100-days"
    Day         = "004"
    Name        = "Example Bucket"
    Environment = "Dev"
  }
}
