module "cloudtrail" {
  source = "./modules/s3-sns"

  coralogix_region = "Europe"
  private_key      = "2fa1aadf-d7dd-f7a1-253c-7a8b14e6409c"
  ssm_enable       = "false"
  integration_type        = "cloudtrail-sns"
  layer_arn        = "<your layer arn>"
  application_name = "cloudtrail"
  s3_key_prefix = "123"
  subsystem_name   = "logs"
  s3_bucket_name   = "gr-integrations-aws-testing"
    sns_topic_name     = "gr-topic-integration"
}