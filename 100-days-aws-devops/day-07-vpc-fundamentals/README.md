# Day 007 — VPC Fundamentals: Subnets, Route Tables, and IGW

## Summary
Build a minimal **VPC** with subnets, route tables, and an Internet Gateway (IGW). Demonstrate the basics of private vs public subnets, routing, and network isolation.

## Architecture
- **VPC**: CIDR block 10.0.0.0/16
- **Subnets**:
  - Public subnet: 10.0.1.0/24
  - Private subnet: 10.0.2.0/24
- **Internet Gateway (IGW)** attached to VPC
- **Route Tables**:
  - Public route table: default route to IGW, associated with public subnet
  - Private route table: local routes only (optionally to NAT Gateway if needed)
- **Tags**:
  - `Project=aws-devops-100-days`
  - `Day=007`
  - `Owner=<your-github-handle>`
  - `Environment=dev`

## Prerequisites
- AWS CLI v2 configured (Day 001)
- Terraform ≥ 1.6
- Permissions to create VPC, subnets, route tables, and IGW

## Steps to Reproduce

### Terraform Example
```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "day007-vpc"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name        = "day007-igw"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"

  tags = {
    Name        = "day007-public-subnet"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name        = "day007-private-subnet"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "day007-public-rt"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "day007-private-rt"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
```

Run:
```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply -auto-approve
```

## Verification
- Run:
```bash
aws ec2 describe-vpcs --filters "Name=tag:Day,Values=007"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"
```
- Confirm:
  - Public subnet has route to IGW
  - Private subnet has no direct route to IGW

## Teardown
```bash
terraform destroy -auto-approve
```

## Cost Notes
- VPC, subnets, IGW, and route tables are **free**.
- Costs accrue only when launching resources inside (e.g., NAT Gateway, EC2).

## Learnings / Gotchas
- Subnets live in **one AZ**; plan multiple subnets for HA.
- Default route tables exist, but explicit ones provide clarity.
- NAT Gateway is **not free**; avoid unless needed for private subnets.
- Route propagation is key when connecting VPCs with TGW or peering.

## References
- [AWS VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [Terraform AWS VPC Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
