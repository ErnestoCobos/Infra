variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for voltaflow domain"
  type        = string
  default     = "35a0feb5ddb5d2fc3b5c313b911206fc"
}
