module "s3" {
  source = "./modules/s3"

  coralogix_region = "Europe"
  private_key      = "2fa1aadf-d7dd-f7a1-253c-7a8b14e6409c"
  application_name = "s3"
  subsystem_name   = "logs"
  s3_bucket_name   = "gr-integrations-aws-testing"
  integration_type = "s3"
}