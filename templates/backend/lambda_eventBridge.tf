resource "aws_cloudwatch_event_rule" "example" {
  name                = "example-rule"
  description         = "Example EventBridge rule"
  event_pattern       = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["running"]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "example" {
  rule      = aws_cloudwatch_event_rule.example.name
  arn       = "your_lambda_function_arn"
}