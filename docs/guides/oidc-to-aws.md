# GitHub Actions → AWS via OIDC (No Static Keys)

High level steps:
1. Create an IAM role with a trust policy for GitHub's OIDC provider (`token.actions.githubusercontent.com`).
2. Limit `aud` to `sts.amazonaws.com` and restrict `sub` to your repo and branch, e.g.:
   - `repo:<owner>/<repo>:ref:refs/heads/main`
3. Attach least‑privilege policies to the role.
4. In your workflow, request the role with `aws-actions/configure-aws-credentials` using `role-to-assume`.
5. Remove any long‑lived AWS keys from GitHub Secrets.

> This repo keeps CI "plan/validate" only by default; deploys (if any) should require manual approval and target ephemeral/sandbox accounts.
