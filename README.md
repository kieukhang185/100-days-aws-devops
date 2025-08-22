# 100 Days of DevOps on AWS

![progress](https://img.shields.io/badge/progress-1%2F100-blue)

A public, versioned portfolio of 100 days of hands‑on DevOps on AWS. Each day is self‑contained and reproducible.

## Prerequisites
- AWS account (sandbox/dev)
- AWS CLI v2
- Terraform ≥ 1.6
- Docker
- Python ≥ 3.11 & pip
- Node.js (if using CDK)
- Git & GitHub CLI (`gh`)

## Repository Layout
```
aws-devops-100-days/
├─ aws-devops-100-days/
|  ├─ day-001-aws-cli-profiles-mfa/
|  └─ README.md
├─ README.md
├─ LICENSE
├─ .gitignore
├─ .editorconfig
├─ .pre-commit-config.yaml
├─ pyproject.toml           # ruff config
├─ Makefile
├─ .github/
│  ├─ workflows/ci.yml
│  ├─ ISSUE_TEMPLATE.md
│  └─ PULL_REQUEST_TEMPLATE.md
├─ templates/
│  ├─ DAY_README.md
│  └─ skeleton/             # Minimal Terraform starter
├─ docs/
│  ├─ architecture/
│  └─ guides/oidc-to-aws.md
├─ tools/
│  ├─ scripts/verify_aws.sh
│  └─ modules/              # (optional in future days)
```

## How to use this repo
Clone, create a branch for the day you’re working on, and push PRs to `main` when CI is green.

```bash
git clone <your-fork-or-repo-url> aws-devops-100-days
cd aws-devops-100-days
git switch -c day-001-aws-cli-profiles-mfa
```

Each day folder includes a README with: objective, prerequisites, steps, verification, teardown, and learnings.

### Common Make targets
```bash
make lint          # shellcheck + ruff
make tf-init       # init terraform for all dirs
make tf-fmt        # check fmt across all terraform dirs
make tf-validate   # validate terraform for all dirs
```

## Cost & Safety
- Use a sandbox account.
- Tag all resources: `Project=aws-devops-100-days, Day=XYZ, Owner=<github>, Environment=dev`.
- Tear down everything at the end of each day.

## OIDC from GitHub Actions to AWS
See `docs/guides/oidc-to-aws.md` for how to enable deployments without long‑lived keys.

## Progress Tracker (check off as you go)
- [ ] Day 001 — AWS CLI, Profiles, and MFA
- [ ] Day 002 — Least‑Privilege IAM User and Groups
- [ ] Day 003 — Budgets and Cost Alerts
- [ ] Day 004 — Tagging Strategy
- [ ] Day 005 — S3 Basics
- [ ] ...
- [ ] Day 100 — Capstone

