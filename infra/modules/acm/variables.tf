variable "domain_name" {
  description = "Domain name for the certificate"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the certificate (optional, used for validation)"
  type        = string
  default     = ""
}

variable "existing_certificate_arn" {
  description = "Optional: Use an existing validated certificate ARN instead of creating a new one"
  type        = string
  default     = ""
}

