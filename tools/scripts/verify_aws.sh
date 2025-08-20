#!/usr/bin/env bash
set -Eeuo pipefail

PROFILE="${1:-default}"
echo "Verifying AWS STS with profile: $PROFILE"
aws sts get-caller-identity --profile "$PROFILE" --output json

