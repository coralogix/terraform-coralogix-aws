data "aws_caller_identity" "this" {}

module "s3" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = var.coralogix_region
  CustomDomain       = var.CustomDomain
  private_key        = var.private_key
  SSM_enable         = var.SSM_enable
  LayerARN           = var.LayerARN
  application_name   = var.application_name
  subsystem_name     = var.subsystem_name
  package_name       = "vpc-flow-logs"
  s3_bucket_name     = var.s3_bucket_name
  s3_key_prefix      = coalesce(var.s3_key_prefix, "AWSLogs/${data.aws_caller_identity.this.account_id}/vpcflowlogs/")
  s3_key_suffix      = var.s3_key_suffix
  memory_size        = var.memory_size
  timeout            = var.timeout
  sampling_rate      = var.sampling_rate
  architecture       = var.architecture
  notification_email = var.notification_email
  debug              = var.debug
  tags               = var.tags
}
