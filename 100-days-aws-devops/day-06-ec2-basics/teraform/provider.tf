provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = merge(
      {
        Project     = "aws-devops-100-days"
        Day         = "006"
        Environment = "dev"
      },
      var.extra_tags
    )
  }
}
