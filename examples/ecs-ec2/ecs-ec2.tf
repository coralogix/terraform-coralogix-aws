provider "aws" {
}

module "otel_ecs_ec2_coralogix" {
  source                   = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name         = "test-lab-cluster"
  image_version            = "v0.3.1"
  memory                   = 256
  coralogix_region         = "EU1"
  custom_domain            = null
  default_application_name = "YOUR_APPLICATION_NAME"
  default_subsystem_name   = "YOUR_SUBSYSTEM_NAME"
  api_key                  = "1234567890_DUMMY_API_KEY"
}
