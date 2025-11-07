output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.existing_certificate_arn != "" ? var.existing_certificate_arn : (length(aws_acm_certificate.this) > 0 ? aws_acm_certificate.this[0].arn : "")
}

output "certificate_domain_validation_options" {
  description = "Domain validation options for the certificate"
  value       = var.existing_certificate_arn != "" ? [] : (length(aws_acm_certificate.this) > 0 ? aws_acm_certificate.this[0].domain_validation_options : [])
}

