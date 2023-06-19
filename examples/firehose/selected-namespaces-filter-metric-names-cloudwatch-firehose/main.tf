module "cloudwatch_firehose_coralogix" {
  source                            = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream                   = var.coralogix_firehose_stream_name
  privatekey                        = var.coralogix_privatekey
  include_all_namespaces            = var.include_all_namespaces
  include_metric_stream_filter      = var.include_metric_stream_filter
  coralogix_region                  = var.coralogix_region
  user_supplied_tags                = var.user_supplied_tags
  cloudwatch_retention_days         = var.cloudwatch_retention_days
}
