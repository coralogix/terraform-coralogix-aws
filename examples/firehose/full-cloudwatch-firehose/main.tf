module "cloudwatch_firehose_coralogix" {
  source           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream  = var.firehose_stream
  private_key      = var.private_key
  coralogix_region = var.coralogix_region
}
