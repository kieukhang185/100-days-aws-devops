# Day 002 — Create a Least-Privilege IAM User and Groups

## Summary
Create a least-privilege **IAM user** and assign it to a group with scoped policies. Demonstrate separation of duties and the principle of least privilege.

## Architecture
- **IAM Group**: `DevOpsReadOnly`
- **IAM Policy**: `ReadOnlyAccess` (AWS managed) or custom narrowed policy
- **IAM User**: `devops-learner`
- User added to the group
- MFA enforced (optional)

## Prerequisites
- AWS CLI v2 configured (from Day 001)
- Terraform ≥ 1.6 (if using IaC)
- IAM permissions to create users, groups, and policies
- Tags required:
  - `Project=aws-devops-100-days`
  - `Day=002`
  - `Owner=<your-github-handle>`
  - `Environment=dev`

## Steps to Reproduce

### Terraform
```bash
# Initialize
terraform init
# or to upgrade terraform to latest version
terraform init -upgrade

# Format & validate
terraform fmt -check
terraform validate

# Plan & apply
terraform plan
terraform apply -auto-approve
```

## Verification
- Run:
  ```bash
  aws iam list-groups-for-user --user-name devops-learner
  ```
  Ensure the output shows the group `DevOpsReadOnly`.

- Try listing S3 buckets with this user’s credentials:
  ```bash
  aws s3 ls --profile devops-learner
  ```
  Should succeed.

- Try creating a bucket:
  ```bash
  aws s3 mb s3://test-bucket-iam-002 --profile devops-learner
  ```
  Should fail (read-only enforcement).

## Teardown
```bash
terraform destroy -auto-approve
```

Or via CLI:
```bash
aws iam remove-user-from-group --user-name devops-learner --group-name DevOpsReadOnly
aws iam delete-user --user-name devops-learner
aws iam delete-group --group-name DevOpsReadOnly
```

## Cost Notes
- No cost (IAM is free).
- Only risk is leaving orphaned users/groups. Always teardown.

## Learnings / Gotchas
- MFA isn’t enforced by default; requires a policy or console settings.
- IAM users should be avoided in production; prefer **OIDC federation** (covered in Day 015).
- Policy scoping is critical: start with `ReadOnlyAccess`, then narrow down.

## References
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Terraform AWS IAM User Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user)
