resource "aws_api_gateway_rest_api" "example" {
  name        = "example-api"
  description = "Example API Gateway"
}

resource "aws_api_gateway_resource" "example" {
  parent_id = aws_api_gateway_rest_api.example.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.example.id
  path_part = "example"
}

resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method
  integration_http_method = "GET"
  type = "HTTP_PROXY"
  uri = "http://example.com"
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [aws_api_gateway_integration.example]
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name = "prod"
}