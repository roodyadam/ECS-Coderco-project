# Use existing certificate if provided, otherwise create a new one
resource "aws_acm_certificate" "this" {
  count             = var.existing_certificate_arn == "" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.domain_name}-certificate"
  }
}

# Certificate validation will be handled by Route53 module after DNS records are created

