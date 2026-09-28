# Security Model

## Zero Trust principles

The project follows:

- Verify explicitly
- Use least privilege
- Assume breach
- Reduce exposed attack surface
- Separate public edge services from private applications

## WAF controls

The lab demonstrates blocking common sensitive-path probes and challenging suspicious administrative POST traffic. Production rules should be tuned against application telemetry to reduce false positives.

## Identity

Access policies are identity-based in the example. A production implementation should add device posture, MFA, group membership, session controls and risk-based signals appropriate to the environment.

## Secrets

Never commit:

- Cloudflare API tokens
- Tunnel credentials
- AI provider keys
- Origin credentials
- Terraform state containing secrets

Use GitHub Actions secrets, Cloudflare secret bindings, or another approved secret manager.
