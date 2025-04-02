data "aws_route53_zone" "selected_zone" {
  name         = var.domain_name # e.g., "dev.yourdomain.com."
  private_zone = false
}

# Route53 Record for Load Balancer
resource "aws_route53_record" "webapp_dns" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = var.domain_name # e.g., "dev.yourdomain.com"
  type    = "A"

  alias {
    name                   = aws_lb.web_alb.dns_name
    zone_id                = aws_lb.web_alb.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_lb.web_alb]
}
