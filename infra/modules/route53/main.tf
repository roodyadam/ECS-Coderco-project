# Normalize domain name 
locals {
  
  domain_clean           = replace(var.domain_name, "/\\.$/", "")
  domain_name_normalized = "${local.domain_clean}."

 
  zone_id = var.hosted_zone_id != "" ? var.hosted_zone_id : data.aws_route53_zone.main[0].zone_id
}


data "aws_route53_zone" "main" {
  count        = var.hosted_zone_id == "" ? 1 : 0
  name         = local.domain_name_normalized
  private_zone = false
}


resource "aws_route53_record" "alb" {
  zone_id         = local.zone_id
  name            = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  type            = "A"
  allow_overwrite = true 

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

