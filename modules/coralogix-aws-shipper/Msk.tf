resource "aws_lambda_event_source_mapping" "msk_event_mapping" {
  for_each          = var.msk_topic_name != null ? toset(var.msk_topic_name) : toset([])
  event_source_arn  = var.msk_cluster_arn
  depends_on        = [module.lambda]
  function_name     = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  starting_position = "LATEST"
  topics            = [each.value]
}
