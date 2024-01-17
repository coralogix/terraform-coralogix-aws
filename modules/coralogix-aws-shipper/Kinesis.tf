resource "aws_lambda_event_source_mapping" "example" {
  count = var.Kinesis_stream_name != null ? 1 : 0
  event_source_arn  = data.aws_kinesis_stream.kinesis_stream[0].arn
  function_name     = module.locals.integration.function_name 
  starting_position = "LATEST"
}