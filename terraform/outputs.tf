output "worker_hostname" {
  description = "Worker DNS hostname."
  value       = local.worker_fqdn
}

output "protected_application" {
  description = "Zero Trust protected hostname."
  value       = var.zero_trust_application_hostname
}

output "branch_tunnels" {
  description = "Five branch tunnel IDs."
  value = {
    for name, tunnel in cloudflare_zero_trust_tunnel_cloudflared.branch :
    name => tunnel.id
  }
}
