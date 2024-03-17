# Recurso AWS Certificate Manager
resource "aws_acm_certificate" "example" {
  domain_name       = "example.com"
  validation_method = "DNS"
}