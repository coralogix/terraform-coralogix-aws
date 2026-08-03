mock_provider "aws" {}

mock_provider "external" {}

mock_provider "local" {}

mock_provider "null" {}

mock_provider "random" {}

run "accepts_per_integration_api_key" {
  command = plan

  variables {
    coralogix_region    = "EU1"
    api_key             = ""
    telemetry_mode      = "logs"
    log_export_protocol = "otlp_grpc"
    otlp_endpoint       = ""

    create_execution_role = false
    execution_role_arn    = "arn:aws:iam::123456789012:role/test-role"
    s3_notification       = false

    integration_info = {
      logs = {
        s3_bucket_name                   = "test-bucket"
        application_name                 = "test-application"
        subsystem_name                   = "test-subsystem"
        integration_type                 = "S3"
        api_key                          = "integration-api-key"
        store_api_key_in_secrets_manager = false
      }
    }
  }
}
