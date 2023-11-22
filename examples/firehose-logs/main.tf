module "cloudwatch_firehose_coralogix" {
  source                    = "github.com/coralogix/terraform-coralogix-aws//modules/firehose-logs"
  firehose_stream           = var.firehose_stream
  private_key               = var.private_key
  coralogix_region          = var.coralogix_region
  integration_type_logs     = "Default"
  source_type_logs          = "DirectPut"
  user_supplied_tags        = var.user_supplied_tags
  cloudwatch_retention_days = var.cloudwatch_retention_days
}
