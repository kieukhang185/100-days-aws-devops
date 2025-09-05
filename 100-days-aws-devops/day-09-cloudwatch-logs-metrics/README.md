# Day 009 — CloudWatch Logs, Metrics, and Dashboards 101

## Summary
Learn the basics of **Amazon CloudWatch** by creating a log group, publishing custom metrics, and visualizing them in a dashboard. Demonstrate collecting logs from EC2 via the CloudWatch Agent and setting up a simple alarm.

## Architecture
- **CloudWatch Log Group**: `/aws/devops/day009`
- **EC2 instance**: Amazon Linux with CloudWatch Agent installed
- **Custom Metric**: e.g., `CPUUtilization`, `MemoryUsage`
- **CloudWatch Dashboard**: displays metrics in widgets
- **Alarm**: triggers when CPU > 70% for 5 minutes
- **Tags**:
  - `Project=aws-devops-100-days`
  - `Day=009`
  - `Owner=<your-github-handle>`
  - `Environment=dev`

## Prerequisites
- AWS CLI v2 configured
- Terraform ≥ 1.6
- Permissions: CloudWatch, EC2, IAM
- EC2 instance with IAM role (`CloudWatchAgentServerPolicy`)

## Steps to Reproduce

### Terraform Example
```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudwatch_log_group" "day009" {
  name              = "/aws/devops/day009"
  retention_in_days = 7
  tags = {
    Project     = "aws-devops-100-days"
    Day         = "009"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

# Example custom metric alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "day009-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU > 70% for 5 min"
  dimensions = {
    InstanceId = "<your-instance-id>"
  }
  tags = {
    Project     = "aws-devops-100-days"
    Day         = "009"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}

resource "aws_cloudwatch_dashboard" "day009" {
  dashboard_name = "day009-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 6,
        height = 6,
        properties = {
          metrics = [["AWS/EC2", "CPUUtilization", "InstanceId", "<your-instance-id>"]]
          period  = 300
          stat    = "Average"
          region  = "us-east-1"
          title   = "EC2 CPU Utilization"
        }
      }
    ]
  })
}
```

Run:
```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -var="instance_id=<i-xxxx>"
terraform apply -auto-approve
```

### Install CloudWatch Agent on EC2
```bash
# On Amazon Linux 2/2023
sudo yum install -y amazon-cloudwatch-agent

# On ubuntu
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Create config file
cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "metrics": {
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "swap": { "measurement": ["swap_used_percent"] }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          { "file_path": "/var/log/messages", "log_group_name": "/aws/devops/day009", "log_stream_name": "{instance_id}" }
        ]
      }
    }
  }
}
EOF

# Start agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl   -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
```

## Verification
- In CloudWatch console:
  - Logs visible in `/aws/devops/day009`
  - Dashboard shows CPU metrics
  - Alarm status becomes **ALARM** if threshold is exceeded
- CLI:
```bash
aws cloudwatch describe-alarms --alarm-names day009-high-cpu
aws logs describe-log-groups --log-group-name-prefix /aws/devops/day009
```

## Teardown
```bash
terraform destroy -auto-approve
# Also stop and terminate EC2 if created
```

## Cost Notes
- CloudWatch metrics: free for basic EC2 metrics, custom metrics cost after free tier
- Logs: $0.50 per GB ingested (first 5GB free)
- Dashboards: free up to 3 dashboards

## Learnings / Gotchas
- Default EC2 metrics (CPU, disk I/O) are free; memory requires CloudWatch Agent
- Logs require explicit agent or service integration
- Dashboards are JSON-based; can be automated with IaC
- Alarms are powerful but can generate noise if thresholds are too low

## References
- [CloudWatch User Guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html)
- [CloudWatch Agent Setup](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
- [Terraform CloudWatch Resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)
