resource "aws_lambda_permission" "cloudwatch_trigger_premission" {
  depends_on    = [module.lambda]
  for_each      =  var.log_group_prefix == null ? local.log_groups : local.log_group_prefix 
  action        = "lambda:InvokeFunction"
  function_name = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  principal     = "logs.amazonaws.com"
  source_arn    = var.log_group_prefix == null ? "${data.aws_cloudwatch_log_group.this[each.key].arn}:*" : "arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:log-group:${local.log_group_prefix[each.value]}*:*"
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  depends_on      = [aws_lambda_permission.cloudwatch_trigger_premission, module.lambda]
  for_each        = local.log_groups
  name            = "${module.lambda.integration.lambda_function_name}-Subscription-${each.key}"
  log_group_name  = data.aws_cloudwatch_log_group.this[each.key].name
  destination_arn = module.lambda.integration.lambda_function_arn
  filter_pattern  = ""
}