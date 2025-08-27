# Day 005 — S3 Basics: Buckets, Versioning, and Lifecycle Rules

## Summary
Learn the basics of **Amazon S3** by creating a bucket, enabling **versioning**, and applying a **lifecycle rule** to transition or expire objects. This ensures cost optimization and data protection.

## Architecture
- One S3 bucket named `day005-s3-demo-<unique>`
- Enable **Bucket Versioning**
- Add **Lifecycle rule**:
  - Transition noncurrent versions to **S3 Standard-IA** after 30 days
  - Expire objects after 365 days
- Tags applied to the bucket:
  - `Project=aws-devops-100-days`
  - `Day=005`
  - `Owner=<your-github-handle>`
  - `Environment=dev`

## Prerequisites
- AWS CLI v2 configured (from Day 001)
- Terraform ≥ 1.6
- IAM permissions to create and manage S3 buckets

## Steps to Reproduce

### Terraform Example
```hcl
resource "aws_s3_bucket" "demo" {
  bucket = "day005-s3-demo-${random_id.rand.hex}"

  tags = {
    Project     = "aws-devops-100-days"
    Day         = "005"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "demo_versioning" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "demo_lifecycle" {
  bucket = aws_s3_bucket.demo.id

  rule {
    id     = "lifecycle"
    status = "Enabled"

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }
  }
}

resource "random_id" "rand" {
  byte_length = 4
}
```

Run:
```bash
terraform init
terraform fmt -check
terraform validate
terraform apply -auto-approve
```

## Verification
- List bucket:
  ```bash
  aws s3 ls
  ```
  Confirm bucket `day005-s3-demo-*` exists.

- Check versioning:
  ```bash
  aws s3api get-bucket-versioning --bucket day005-s3-demo-<unique>
  ```
  Should return `"Status": "Enabled"`.

- Check lifecycle:
  ```bash
  aws s3api get-bucket-lifecycle-configuration --bucket day005-s3-demo-<unique>
  ```

- Upload and delete a file, then check that old versions are retained.

## Teardown
```bash
terraform destroy -auto-approve
```

If bucket not empty, empty first:
```bash
aws s3 rm s3://day005-s3-demo-<unique> --recursive
```

## Cost Notes
- Buckets are free; storage incurs charges after free tier (5 GB/month).
- Lifecycle transitions may incur costs if objects are transitioned.
- Cleanup to avoid unexpected charges.

## Learnings / Gotchas
- Bucket names must be **globally unique**.
- Lifecycle rules take time to apply (not immediate).
- Always empty buckets before destroying with Terraform to avoid errors.
- Versioning protects against accidental deletes but increases storage usage.

## References
- [Amazon S3 Documentation](https://docs.aws.amazon.com/s3/index.html)
- [Terraform S3 Bucket Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)
