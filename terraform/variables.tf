variable "cloudflare_api_token" {
  description = "Cloudflare API token with the minimum permissions required by the resources being managed."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the demo domain."
  type        = string
}

variable "domain" {
  description = "Demo DNS zone, for example example.com."
  type        = string
}

variable "worker_hostname" {
  description = "Hostname used by the Worker."
  type        = string
  default     = "api"
}

variable "protected_origin" {
  description = "Origin hostname behind Cloudflare."
  type        = string
  default     = "origin.example.internal"
}

variable "zero_trust_application_hostname" {
  description = "Private application hostname exposed through Access."
  type        = string
  default     = "internal.example.com"
}

variable "allowed_email_domain" {
  description = "Email domain allowed by the demo Access policy."
  type        = string
  default     = "example.com"
}

variable "branch_locations" {
  description = "Five branch labels used by the lab architecture."
  type        = list(string)
  default     = ["branch-01", "branch-02", "branch-03", "branch-04", "branch-05"]
}
