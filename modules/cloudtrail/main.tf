data "aws_caller_identity" "this" {}

module "s3" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = var.coralogix_region
  private_key        = var.private_key
  application_name   = var.application_name
  subsystem_name     = var.subsystem_name
  package_path       = "${path.module}/dist/package.zip"
  s3_bucket_name     = var.s3_bucket_name
  s3_key_prefix      = coalesce(var.s3_key_prefix, "AWSLogs/${data.aws_caller_identity.this.account_id}/CloudTrail/")
  s3_key_suffix      = var.s3_key_suffix
  memory_size        = var.memory_size
  timeout            = var.timeout
  architecture       = var.architecture
  notification_email = var.notification_email
  tags               = var.tags
}
