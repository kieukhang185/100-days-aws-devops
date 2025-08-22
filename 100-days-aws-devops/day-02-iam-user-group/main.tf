

terraform {
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

resource "aws_iam_user" "iam_devops_user" {
  name = "devops-learner"
  tags = {
    Environment = "Development"
    Project     = "aws-devops-100-days"
    Day         = "002"
    Environment = "dev"
  }
}

resource "aws_iam_group" "iam_devops_group" {
  name = "DevOpsReadOnly"
}

resource "aws_iam_policy" "iam_read_only_policy" {
  name        = "S3ReadOnlyAccess"
  description = "IAM policy for read-only access to S3 buckets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListAllMyBuckets",
      ]
      Resource = [
        "arn:aws:s3:::*",
        "arn:aws:s3:::*/*",
      ]
    }]
  })
}
resource "aws_iam_group_policy_attachment" "iam_devops_group_policy_attachment" {
  group      = aws_iam_group.iam_devops_group.name
  policy_arn = aws_iam_policy.iam_read_only_policy.arn
}

resource "aws_iam_user_group_membership" "user_group_association" {
  user   = aws_iam_user.iam_devops_user.name
  groups = [aws_iam_group.iam_devops_group.name]
}
