
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

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "day007-vpc"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "gtw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "day007-igw"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Environment = "dev"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "day007-public-subnet"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Environment = "dev"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "day007-private-subnet"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Environment = "dev"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gtw.id
  }

  tags = {
    Name        = "day007-public-route-table"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "day007-private-route-table"
    Project     = "aws-devops-100-days"
    Day         = "007"
    Environment = "dev"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
