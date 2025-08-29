# Day 006 — EC2 Basics: Launch, Secure, and SSH with Session Manager

## Summary
Launch a minimal **EC2 instance** with hardened defaults: **no public SSH**, connect via **AWS Systems Manager Session Manager**, enforce **IMDSv2**, block public exposure, and enable default **EBS encryption**. Verify connectivity and logs, then tear down to avoid costs.

## Architecture
- **EC2**: Amazon Linux 2023, t3.micro (Free Tier)
- **Networking**: Subnet with internet/NAT route; no public IP
- **Security Group**: egress-only (no inbound)
- **IAM Role**: instance profile with `AmazonSSMManagedInstanceCore`
- **Session Manager**: browser/CLI access (no SSH keys)
- **Storage**: 8–10 GiB gp3, encrypted by default
- **IMDSv2**: required
- **Tags**:
  - `Project=aws-devops-100-days`
  - `Day=006`
  - `Owner=<your-github-handle>`
  - `Environment=dev`

## Prerequisites
- AWS CLI v2 configured (Day 001)
- Terraform ≥ 1.6 (if IaC)
- Permissions to create EC2, IAM roles, and SSM associations

## Steps to Reproduce

### Terraform
1. Define EC2, IAM role, instance profile, and SG with no inbound.
2. Enforce IMDSv2 in `metadata_options`.
3. Attach `AmazonSSMManagedInstanceCore` to role.
4. Apply with:
```bash
terraform init
terraform fmt -check && terraform validate
terraform plan -var="subnet_id=<subnet-xxxx>"
terraform apply -auto-approve -var="subnet_id=<subnet-xxxx>"
```

### AWS CLI Quick Demo
- Create IAM role/profile.
- Create SG with egress only.
- Launch EC2 with no public IP, IMDSv2 required, and encrypted EBS.

## Verification
- In **Systems Manager → Fleet Manager**, instance should be **Managed**.
- Start a session:
```bash
aws ssm start-session --target <instance-id>
```
- Check IMDSv2:
```bash
curl -s http://169.254.169.254/latest/meta-data/   # fails
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds:21600")
curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/
```

## Teardown
```bash
terraform destroy -auto-approve
# or with CLI: terminate instance, delete SG, detach+delete IAM role/profile
```

## Cost Notes
- t3.micro / t4g.micro are Free Tier.
- EBS: 10 GiB gp3 = a few cents/month.
- Session Manager free (CloudWatch logs extra if enabled).

## Learnings / Gotchas
- No need for SSH keys — Session Manager is simpler and safer.
- IMDSv2 protects against metadata theft.
- Ensure subnet has NAT/IGW or SSM VPC endpoints for connectivity.
- If instance shows “Not managed” → check IAM role and networking.

## References
- [AWS EC2 Docs](https://docs.aws.amazon.com/ec2/)
- [Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Terraform aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
