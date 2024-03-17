# Recurso AWS WAF
resource "aws_waf_web_acl" "example" {
  name        = "example"
  metric_name = "example-metric"

  default_action {
    type = "ALLOW"
  }

}