# # Request ACM Certificate
# resource "aws_acm_certificate" "webapp_certificate" {
#   domain_name       = var.domain_name
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "*.${var.domain_name}"
#   ]

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "webapp-certificate"
#   }
# }

# # Route53 Record for DNS Validation
# resource "aws_route53_record" "webapp_certificate_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.webapp_certificate.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   zone_id = data.aws_route53_zone.selected_zone.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = 60
#   records = [each.value.record]
# }

# # Validate ACM Certificate
# resource "aws_acm_certificate_validation" "webapp_certificate_validation_complete" {
#   certificate_arn         = aws_acm_certificate.webapp_certificate.arn
#   validation_record_fqdns = [for record in aws_route53_record.webapp_certificate_validation : record.fqdn]
# }
