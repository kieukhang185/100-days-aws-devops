output "vpc_id" {
  value       = aws_vpc.this.id
  description = "Created VPC ID"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Created public subnet ID"
}

output "security_group_id" {
  value       = aws_security_group.no_inbound.id
  description = "Security Group ID (no inbound)"
}

output "instance_id" {
  value       = aws_instance.this.id
  description = "EC2 Instance ID"
}

output "instance_public_ip" {
  value       = aws_instance.this.public_ip
  description = "EC2 public IP (no inbound allowed by SG)"
}

output "iam_role_name" {
  value       = aws_iam_role.ec2_role.name
  description = "IAM Role name"
}

output "instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_profile.name
  description = "Instance Profile name"
}
