module "cloudwatch_firehose_coralogix" {
  source                         = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream                = var.coralogix_firehose_stream_name
  privatekey                     = var.coralogix_privatekey
  enable_cloudwatch_metricstream = false
  coralogix_region               = var.coralogix_region
}
