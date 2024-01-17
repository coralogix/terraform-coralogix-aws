resource "aws_lambda_permission" "cloudwatch_trigger_premission" {
  for_each      = local.log_groups
  action        = "lambda:InvokeFunction"
  function_name = local.log_info.integration.lambda_name == null ? module.locals.integration.function_name : local.log_info.lambda_name
  principal     = "logs.amazonaws.com"
  source_arn    = "${data.aws_cloudwatch_log_group.this[each.key].arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  depends_on = [aws_lambda_permission.cloudwatch_trigger_premission,module.lambda]
  # count = 0
  for_each        = local.log_groups
  name            = "${module.lambda.integration.lambda_function_name}-Subscription-${each.key}"
  log_group_name  = data.aws_cloudwatch_log_group.this[each.key].name
  destination_arn = module.lambda.integration.lambda_function_arn
  filter_pattern  = ""
}