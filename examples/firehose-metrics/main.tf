module "cloudwatch_firehose_metrics_coralogix" {
  source                              = "github.com/coralogix/terraform-coralogix-aws//modules/firehose-metrics"
  firehose_stream                     = var.firehose_stream
  private_key                         = var.private_key
  enable_cloudwatch_metricstream      = var.enable_cloudwatch_metricstream
  integration_type_metrics            = var.integration_type_metrics
  include_metric_stream_namespaces    = var.include_metric_stream_namespaces
  include_metric_stream_filter        = var.include_metric_stream_filter
  additional_metric_statistics_enable = var.additional_metric_statistics_enable
  additional_metric_statistics        = var.additional_metric_statistics
  output_format                       = var.output_format
  coralogix_region                    = var.coralogix_region
  user_supplied_tags                  = var.user_supplied_tags
  cloudwatch_retention_days           = var.cloudwatch_retention_days
}
