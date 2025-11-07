output "record_name" {
  description = "Name of the Route53 record"
  value       = aws_route53_record.alb.name
}

output "record_fqdn" {
  description = "Fully qualified domain name"
  value       = aws_route53_record.alb.fqdn
}

output "certificate_validation_arn" {
  description = "ARN of the validated certificate (currently disabled - validation happens manually)"
  value       = ""  # Validation is handled manually to avoid Terraform dependency issues
}

