module "s3" {
  source = "./modules/s3"

  coralogix_region = "Europe"
  private_key      = "XXXXX-XXXX-XXXX-XXXXXX"
  application_name = "s3"
  subsystem_name   = "logs"
  s3_bucket_name   = "gr-integrations-aws-testing"
  integration_type = "s3"
}