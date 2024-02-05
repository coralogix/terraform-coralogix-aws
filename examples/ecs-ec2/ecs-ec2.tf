provider "aws" {
}

module "otel_ecs_ec2_coralogix" {
  source                   = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name         = var.ecs_cluster_name
  image_version            = var.image_version
  memory                   = var.memory
  coralogix_region         = var.coralogix_region
  default_application_name = var.default_application_name
  default_subsystem_name   = var.default_subsystem_name
  private_key              = var.private_key
  metrics                  = var.metrics
}
