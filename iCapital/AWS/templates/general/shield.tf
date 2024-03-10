# Recurso AWS Shield
resource "aws_shield_protection" "example" {
  resource_arn = "your_resource_arn"
  name = "example"
}