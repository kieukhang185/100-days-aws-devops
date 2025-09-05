# Day 008 — Security Groups vs NACLs: Traffic Controls

## Summary
Understand and implement **Security Groups (SGs)** and **Network ACLs (NACLs)** in a VPC. Compare their roles in controlling traffic, and demonstrate inbound/outbound filtering with a test EC2 instance.

## Architecture
- **VPC**: 10.0.0.0/16
- **Subnets**:
  - Public subnet (10.0.1.0/24) with IGW route
- **Resources**:
  - 1 EC2 instance in the public subnet (Amazon Linux, t3.micro)
- **Security Group**:
  - Allow inbound HTTP (80) and HTTPS (443)
  - Allow SSH (22) **temporarily**, but prefer Session Manager
  - Allow all egress
- **NACL**:
  - Public subnet NACL:
    - Inbound: allow 80, 443, 22 from 0.0.0.0/0
    - Outbound: allow ephemeral ports (1024-65535)
- **Tags**:
  - `Project=aws-devops-100-days`
  - `Day=008`
  - `Owner=<your-github-handle>`
  - `Environment=dev`

## Prerequisites
- AWS CLI v2 configured
- Terraform ≥ 1.6
- VPC + subnet (from Day 007 or default VPC)
- Permissions to create EC2, SGs, and NACLs

## Steps to Reproduce

### Terraform Example
```hcl
provider "aws" {
  region = "us-east-1"
}

variable "subnet_id" {}
variable "ami_id" {}

resource "aws_security_group" "web_sg" {
  name        = "day008-web-sg"
  description = "Allow web + ssh"
  vpc_id      = data.aws_subnet.selected.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH temporary"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = "aws-devops-100-days"
    Day         = "008"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_network_acl" "public_nacl" {
  vpc_id = data.aws_subnet.selected.vpc_id

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  subnet_ids = [data.aws_subnet.selected.id]

  tags = {
    Project     = "aws-devops-100-days"
    Day         = "008"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name        = "day008-ec2"
    Project     = "aws-devops-100-days"
    Day         = "008"
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
terraform plan -var="subnet_id=<subnet-xxxx>" -var="ami_id=<ami-xxxx>"
terraform apply -auto-approve -var="subnet_id=<subnet-xxxx>" -var="ami_id=<ami-xxxx>"
```

## Verification
- Confirm SG allows inbound HTTP, HTTPS, SSH:
```bash
aws ec2 describe-security-groups --group-ids <sg-id>
```
- Confirm NACL rules:
```bash
aws ec2 describe-network-acls --network-acl-ids <nacl-id>
```
- SSH (temporary): `ssh ec2-user@<public-ip>` (if key pair provided)
- Use curl from external host to verify HTTP/HTTPS reachability.

## Teardown
```bash
terraform destroy -auto-approve
```

## Cost Notes
- EC2 t3.micro Free Tier eligible. Otherwise a few cents/hour.
- SGs and NACLs are free.

## Learnings / Gotchas
- **Security Groups** are **stateful**: return traffic automatically allowed.
- **NACLs** are **stateless**: must allow both inbound and outbound explicitly.
- SGs apply at **instance ENI level**; NACLs apply at **subnet level**.
- SGs are easier for most use-cases; NACLs are better for coarse subnet rules.
- Avoid overlapping / conflicting rules to reduce troubleshooting pain.

## References
- [AWS VPC Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [AWS VPC NACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)
- [Terraform aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
- [Terraform aws_network_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl)
