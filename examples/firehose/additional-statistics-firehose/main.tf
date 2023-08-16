module "cloudwatch_firehose_coralogix" {
  source                       = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream              = var.firehose_stream
  private_key                  = var.private_key
  additional_metric_statistics = var.additional_metric_statistics
  coralogix_region             = var.coralogix_region
}
