module "cloudwatch_firehose_logs_coralogix" {
  source                    = "coralogix/aws/coralogix//modules/firehose-logs"
  firehose_stream           = var.firehose_stream
  api_key                   = var.api_key
  coralogix_region          = var.coralogix_region
  integration_type_logs     = "Default"
  source_type_logs          = "DirectPut"
  user_supplied_tags        = var.user_supplied_tags
  cloudwatch_retention_days = var.cloudwatch_retention_days
  server_side_encryption    = var.server_side_encryption
}
