resource "aws_cloudwatch_event_rule" "EventBridgeRule" {
  count       = var.integration_type == "EcrScan" ? 1 : 0
  name        = format("ECR-image-scan-lambda-invoke")
  description = "Event rule for invoking Lambda on ECR image scan"
  event_pattern = jsonencode({
    source      = ["aws.ecr"],
    detail-type = ["ECR Image Scan"],
    detail = {
      scan-status = ["COMPLETE"]
    }
  })

  tags = {
    Name = "ECR-image-scan-lambda-invoke"
  }
}

resource "aws_cloudwatch_event_target" "EventBridgeRuleTarget" {
  depends_on = [aws_cloudwatch_event_rule.EventBridgeRule]
  count      = var.integration_type == "EcrScan" ? 1 : 0
  rule       = aws_cloudwatch_event_rule.EventBridgeRule[0].name
  target_id  = "LambdaFunction"

  arn = element(module.lambda[*].integration.lambda_function_arn, 0)
}


