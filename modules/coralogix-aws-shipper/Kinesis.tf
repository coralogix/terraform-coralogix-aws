resource "aws_lambda_event_source_mapping" "example" {
  depends_on        = [module.lambda]
  count             = var.kinesis_stream_name != null ? 1 : 0
  event_source_arn  = data.aws_kinesis_stream.kinesis_stream[0].arn
  function_name     = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  starting_position = "LATEST"
}