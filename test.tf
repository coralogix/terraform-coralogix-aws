provider "aws" {
  
}

module "coralogix-aws-shipper" {
  source = "./modules/coralogix-aws-shipper"
  integration_type = "S3"
  coralogix_region = "EU1"
  api_key = "cxtp_Mkx3vKv4LBrFtKM9RbPlsGemmPtiBD"
  s3_bucket_name = "gr-shipper-firehose-metrics-test"
  application_name = "{{ $.test_log.parameters.ApplicationName }}"
  subsystem_name = "test-sub-app"
  log_level = "DEBUG"
}
