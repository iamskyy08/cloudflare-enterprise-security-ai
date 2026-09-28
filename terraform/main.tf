locals {
  worker_fqdn = "${var.worker_hostname}.${var.domain}"
}

resource "cloudflare_dns_record" "worker" {
  zone_id = var.cloudflare_zone_id
  name    = var.worker_hostname
  type    = "CNAME"
  content = "workers.dev"
  ttl     = 1
  proxied = true
  comment = "Portfolio Worker hostname placeholder; replace target with deployed Worker routing."
}

resource "cloudflare_dns_record" "origin" {
  zone_id = var.cloudflare_zone_id
  name    = "origin"
  type    = "CNAME"
  content = var.protected_origin
  ttl     = 1
  proxied = true
  comment = "Protected application origin."
}

resource "cloudflare_ruleset" "waf_custom" {
  zone_id = var.cloudflare_zone_id
  name    = "enterprise-edge-security"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules {
    action      = "block"
    description = "Block obvious scanner and exploit URI patterns"
    enabled     = true
    expression  = <<-EOT
      (http.request.uri.path contains "/.env") or
      (http.request.uri.path contains "/wp-config.php") or
      (http.request.uri.path contains "/etc/passwd")
    EOT
  }

  rules {
    action      = "managed_challenge"
    description = "Challenge suspicious high-risk paths"
    enabled     = true
    expression  = <<-EOT
      (http.request.method eq "POST" and http.request.uri.path contains "/admin")
    EOT
  }
}

resource "cloudflare_zero_trust_access_application" "private_app" {
  account_id      = var.cloudflare_account_id
  name            = "Enterprise Private Application"
  type            = "self_hosted"
  session_duration = "8h"

  destinations {
    type = "public"
    uri  = var.zero_trust_application_hostname
  }
}

resource "cloudflare_zero_trust_access_group" "engineering" {
  account_id = var.cloudflare_account_id
  name       = "Engineering - Portfolio Lab"

  include {
    email_domain = var.allowed_email_domain
  }
}

resource "cloudflare_zero_trust_access_policy" "private_app_allow" {
  account_id     = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.private_app.id
  name           = "Allow approved identity domain"
  precedence     = 1
  decision       = "allow"

  include {
    group = [cloudflare_zero_trust_access_group.engineering.id]
  }
}

# Five enterprise branches.
resource "cloudflare_zero_trust_tunnel_cloudflared" "branch" {
  for_each = toset(var.branch_locations)

  account_id = var.cloudflare_account_id
  name       = "zt-${each.key}"
  config_src = "cloudflare"
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "branch" {
  for_each = cloudflare_zero_trust_tunnel_cloudflared.branch

  account_id = var.cloudflare_account_id
  tunnel_id  = each.value.id

  config {
    ingress_rule {
      hostname = "${each.key}.${var.domain}"
      service  = "http://10.10.0.10:8080"
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}
