module "cloudwatch_firehose_coralogix" {
  source                               = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream                      = var.firehose_stream
  private_key                          = var.private_key
  coralogix_region                     = var.coralogix_region
  cloudwatch_metric_stream_custom_name = var.cloudwatch_metric_stream_custom_name
  s3_backup_custom_name                = var.s3_backup_custom_name
  lambda_processor_custom_name         = var.lambda_processor_custom_name
}
