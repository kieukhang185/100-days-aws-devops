resource "aws_instance" "this" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.no_inbound.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  # Enforce IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Ensure SSM agent is enabled (AL2023 usually already is)
  user_data = <<-EOT
    #!/bin/bash
    set -Eeuo pipefail
    systemctl enable amazon-ssm-agent || true
    systemctl start amazon-ssm-agent || true
  EOT

  tags = {
    Name = "${var.name_prefix}"
  }
}
