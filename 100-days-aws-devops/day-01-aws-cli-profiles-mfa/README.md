# Day 001 — AWS CLI, Profiles, and MFA

**Goal:** Install AWS CLI v2, configure a named profile with MFA, and verify identity with STS.

## Prerequisites
- AWS account with a user that can enable/assign MFA
- macOS/Linux with Homebrew or a package manager
- Python 3.11+ (optional)

## Steps
```bash
# 1) Install AWS CLI v2 (macOS via brew; see AWS docs for other OSes)
brew install awscli || true

#Ubuntu/Debian
sudo snap install aws-cli --classic

# 2) Configure a profile
aws configure --profile dev-100days

# 3) (Recommended) Enable a virtual MFA device for your IAM user in the console.
#    Then get your serial ARN and use an MFA code to obtain a session:
read -p "MFA serial (arn:aws:iam::ACCOUNT:user/you or mfa/you): " MFA_SERIAL
read -p "MFA code: " MFA_CODE
aws sts get-session-token   --serial-number "$MFA_SERIAL"   --token-code "$MFA_CODE"   --profile dev-100days   --duration-seconds 43200   --output json > /tmp/dev-100days-session.json

# 4) Export the session credentials into your profile (~/.aws/credentials)
#    (jq recommended; if not available, paste manually)
if command -v jq >/dev/null 2>&1; then
  AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' /tmp/dev-100days-session.json)
  AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' /tmp/dev-100days-session.json)
  AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' /tmp/dev-100days-session.json)
  aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile dev-100days-mfa
  aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile dev-100days-mfa
  aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile dev-100days-mfa
fi

# 5) Verify
```bash
bash tools/scripts/verify_aws.sh dev-100days-mfa
```

## Verification
- `aws sts get-caller-identity --profile dev-100days-mfa` returns your account/user info using the MFA-backed profile.

## Teardown
- Remove temporary session credentials from the `dev-100days-mfa` profile when done.


## Cost Notes
- No AWS resources created; $0.

## Learnings / Gotchas
- Prefer short‑lived credentials with MFA.
- Name your profiles clearly (e.g., `dev-100days`, `prod-foo`).
- Consider using SSO/Identity Center later for passwordless login.

