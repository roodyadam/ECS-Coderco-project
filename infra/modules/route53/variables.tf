variable "domain_name" {
  description = "Domain name for Route53 record"
  type        = string
}

variable "hosted_zone_id" {
  description = "Optional: Route53 hosted zone ID. If provided, will use this instead of looking up by name"
  type        = string
  default     = ""
}

variable "subdomain" {
  description = "Subdomain for the application"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB"
  type        = string
}

variable "certificate_domain_validation_options" {
  description = "Domain validation options from ACM certificate"
  type = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
  default = []
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate to validate"
  type        = string
  default     = ""
}

