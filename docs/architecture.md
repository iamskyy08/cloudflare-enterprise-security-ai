# Architecture

## Traffic flow

### Internet-facing application

1. Client resolves the application hostname through Cloudflare DNS.
2. Traffic reaches the Cloudflare edge.
3. WAF evaluates the request.
4. CDN/cache handles cacheable content.
5. Worker performs application/edge logic.
6. The Worker can call Workers AI for inference.
7. Approved requests reach the protected origin.

### Private application

1. User authenticates through Cloudflare Zero Trust Access.
2. Access evaluates identity and policy.
3. Cloudflare Tunnel provides outbound-only connectivity from the branch/private network.
4. The application remains non-public.

## Five-branch model

| Branch | Tunnel | Example private service |
|---|---|---|
| Branch 01 | zt-branch-01 | 10.10.0.10:8080 |
| Branch 02 | zt-branch-02 | 10.10.0.10:8080 |
| Branch 03 | zt-branch-03 | 10.10.0.10:8080 |
| Branch 04 | zt-branch-04 | 10.10.0.10:8080 |
| Branch 05 | zt-branch-05 | 10.10.0.10:8080 |

The addresses are intentionally lab placeholders; each branch should use its real internal service map.

## Security boundaries

- DNS/edge: authoritative routing and proxying
- WAF: HTTP-layer inspection and enforcement
- Zero Trust: identity-aware access
- Tunnel: outbound private connectivity
- Worker: application/edge policy logic
- Workers AI: model inference
- Origin: application/data layer
