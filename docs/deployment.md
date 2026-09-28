# Deployment Guide

## Terraform

From the repository root:

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Worker

```bash
cd worker
npm install
npx wrangler login
npx wrangler deploy
```

Workers AI is configured through the `AI` binding in `wrangler.toml`.

## CI

The GitHub Actions workflow validates Terraform formatting and configuration. Deployment should be separated into an approval-controlled environment before applying infrastructure to production.

## Production hardening

Before production use:

1. Replace all example domains.
2. Use a narrowly scoped Cloudflare API token.
3. Store Terraform state in a secured remote backend.
4. Protect state access.
5. Add device posture and MFA policies.
6. Configure real branch connector credentials outside Git.
7. Review WAF rules against application behavior.
8. Add rate limiting and bot controls where appropriate.
9. Configure logging/SIEM integration.
10. Pin tested Worker/runtime dependencies.
