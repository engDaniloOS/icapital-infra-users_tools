# Recurso AWS Route 53
resource "aws_route53_record" "example" {
  zone_id = "your_zone_id"
  name    = "example.com"
  type    = "A"
  ttl     = "300"
  records = ["your_route_53_target"]
}