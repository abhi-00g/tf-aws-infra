# Request ACM Certificate (only for Dev)
resource "aws_acm_certificate" "dev_cert" {
  count = var.aws_profile == "dev" ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "dev-ssl-certificate"
  }
}

# Create Route53 CNAME records (only if dev)
resource "aws_route53_record" "cert_validation" {
  for_each = var.aws_profile == "dev" ? {
    for dvo in aws_acm_certificate.dev_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

# Validate ACM Certificate (only if dev)
resource "aws_acm_certificate_validation" "dev_cert_validation" {
  count = var.aws_profile == "dev" ? 1 : 0

  certificate_arn         = aws_acm_certificate.dev_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
