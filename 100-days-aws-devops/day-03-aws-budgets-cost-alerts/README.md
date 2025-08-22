# Day 003 — Configure AWS Budgets and Cost Alerts

## Summary
Set up **AWS Budgets** with **email alerts** to catch unexpected spend early. Create monthly cost and forecast alerts with low thresholds (e.g., **$5 / $15 / $30**) and document verification and teardown.

## Architecture
- **AWS Budgets** (Cost type: `COST`) scoped to the entire account.
- **Notifications** via email (SNS optional; email is simplest to start).
- **Two alerts per budget**: `Actual` and `Forecasted` spend.
- Tagging on all related IaC resources:
  - `Project=aws-devops-100-days`
  - `Day=003`
  - `Owner=<your-github-handle>`
  - `Environment=dev`

## Prerequisites
- AWS account with access to **Billing** (Owner or Billing permissions).
- AWS CLI v2 installed and configured.
- Terraform ≥ 1.6 (optional, if using IaC).
- An email address you can receive alerts at.
- (Recommended) From Day 001, a named AWS profile and MFA set up.

## Steps to Reproduce

### Option A — Terraform (recommended)
Create `main.tf` with the following (adjust email and thresholds as needed):

```hcl
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "alert_email" {
  type = string
}
```

# Monthly cost budget (whole account) with two notifications: Actual and Forecasted
```hcl
resource "aws_budgets_budget" "monthly_cost" {
  name              = "Monthly-Cost-Guardrail"
  budget_type       = "COST"
  limit_amount      = "30"              # upper monthly limit in USD
  limit_unit        = "USD"
  time_period_start = formatdate("YYYY-MM-01_00:00", timestamp())
  time_unit         = "MONTHLY"

  cost_types {
    include_credit             = true
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = true
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_blended                = false
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 5         # USD
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 15        # USD
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.alert_email]
  }

  tags = {
    Project     = "aws-devops-100-days"
    Day         = "003"
    Owner       = "YOUR_GITHUB_HANDLE"
    Environment = "dev"
  }
}
```

## Run

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -var="alert_email=you@example.com"
terraform apply -auto-approve -var="alert_email=you@example.com"
```
You can add additional budgets (e.g., a Threshold at $30 for forecasted spend) by duplicating the aws_budgets_budget with another name.

### Option B — Console (quick demo)

- Open `Billing & Cost Management → Budgets → Create budget`.
- Type: `Cost budget → Monthly → Amount 30 USD`
- Add two Alert thresholds:
- `Actual > 5 USD → email you@example.com`
- `Forecasted > 15 USD → email you@example.com`
- Create budget and confirm the verification email if prompted.

### Verification
- Budget exists: In console, see the budget Monthly-Cost-Guardrail under Budgets.
- Email subscription: Ensure you received any verification/confirmation email and accepted it (if required).
- Alert path works (quick test options):
- Temporarily lower thresholds (e.g., set Actual to 0.01 USD) in Terraform and apply. If your month-to-date cost exceeds that, you should receive an alert shortly.
- Or wait until spend crosses the Actual threshold naturally (e.g., when running later days).
- Heads-up: Budgets evaluate periodically (not instant). Alerts may take some time after the threshold is crossed.

### Teardown
- If created with Terraform: Always show details `terraform destroy -auto-approve`
- If created via console:
Delete the budget from Billing → Budgets.
Remove any associated SNS topics or email subscribers you created (if you used SNS).

## Cost Notes
- Budgets themselves have minimal to no cost for small numbers. Keep the count low and delete when done. Check the current AWS Budgets pricing if you plan to create many budgets.
- Alerts via email are free; SNS may incur negligible charges.

## Learnings / Gotchas
- Permissions: IAM users need the Billing permissions (or be account root) to manage budgets; in orgs, some settings may be restricted.
- Timing: Budget evaluations aren’t real-time; alerts may lag.
- Scope: This example budgets the entire account. You can also scope by Service, Tag, or Linked Account (in Organizations).
- Forecast vs Actual: Forecasted alerts warn before you exceed the final limit; Actual alerts trigger after spend passes the threshold.
- Pair this with Day 004 tagging to create tag-scoped budgets (e.g., Project=aws-devops-100-days).

## References
- AWS Budgets (User Guide): https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-managing-costs.html
- Terraform aws_budgets_budget: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget
