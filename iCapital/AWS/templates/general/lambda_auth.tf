# Recurso AWS Lambda
resource "aws_lambda_function" "example" {
    role = "example"
    function_name = "example"
    handler       = "example.handler"
    runtime       = "nodejs14.x"
    filename      = "path/to/your/function.zip"
}