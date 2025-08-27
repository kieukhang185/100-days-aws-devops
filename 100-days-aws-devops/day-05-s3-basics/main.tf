

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
  bucket = "day005-s3-basics-demo-${random_id.rand.hex}"

  tags = {
    Project     = "aws-devops-100-days"
    Day         = "005"
    Name        = "Example Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "demo_versioning" {
    bucket = aws_s3_bucket.example.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "demo_lifecycle" {
    bucket = aws_s3_bucket.example.id

    rule {
        id      = "lifecycle"
        status  = "Enabled"

        noncurrent_version_transition {
            noncurrent_days = 30
            storage_class   = "STANDARD_IA"
        }

        expiration {
            days = 365
        }
    }
}

resource "random_id" "rand" {
  byte_length = 4
}
