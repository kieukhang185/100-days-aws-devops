# Day 004 — Tagging Strategy for Cost Allocation

## Summary
Define and apply a consistent **tagging strategy** for AWS resources to enable **cost allocation**, **governance**, and **automation**. Demonstrate applying tags via Terraform and confirm visibility in the AWS Billing console.

## Architecture
- Standard tag keys:
  - `Project=aws-devops-100-days`
  - `Day=004`
  - `Owner=<your-github-handle>`
  - `Environment=dev`
- Tags applied to sample resources (e.g., S3 bucket, IAM user, EC2 instance).
- Enable **Cost Allocation Tags** in Billing console.

## Prerequisites
- AWS CLI v2 configured (from Day 001).
- Terraform ≥ 1.6.
- Permissions to enable cost allocation tags (Billing access).

## Steps to Reproduce

### 1. Define Tagging Standards
Create a simple tagging policy document:
```text
Key: Project        | Value: aws-devops-100-days
Key: Day            | Value: 004
Key: Owner          | Value: <github-handle>
Key: Environment    | Value: dev/test/prod
```

### 2. Apply Tags in Terraform
Example S3 bucket with tags:
```hcl
resource "aws_s3_bucket" "example" {
  bucket = "day004-tagging-demo"

  tags = {
    Project     = "aws-devops-100-days"
    Day         = "004"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}
```

Run:
```bash
terraform init
terraform fmt -check
terraform validate
terraform apply -auto-approve
```

### 3. Enable Tags for Cost Allocation
1. In the AWS console, go to **Billing → Cost Allocation Tags**.
2. Select your custom tags (e.g., `Project`, `Day`, `Owner`, `Environment`).
3. Activate them for reporting.

## Verification
- In AWS console, check **Billing → Cost Explorer → Group by Tags**.
- Ensure spend is grouped by `Project` or `Day`.
- Use CLI to check tags:
  ```bash
  aws s3api get-bucket-tagging --bucket day004-tagging-demo
  ```

## Teardown
```bash
terraform destroy -auto-approve
```

## Cost Notes
- S3 bucket may incur negligible storage cost if objects are added. Delete bucket promptly.
- Tags themselves are free.

## Learnings / Gotchas
- Tags are **case-sensitive** and must be consistent across resources.
- Not all AWS services support tagging equally (check docs).
- Must **activate tags** in billing before they appear in Cost Explorer.
- Good tagging helps later days (budgets, automation, security).

## References
- [AWS Tagging Best Practices](https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/tagging-best-practices.html)  
- [Terraform aws_s3_bucket Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)  
