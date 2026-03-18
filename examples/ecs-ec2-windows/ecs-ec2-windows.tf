module "otel_ecs_ec2_windows_coralogix" {
  # For registry: source = "coralogix/aws/coralogix//modules/ecs-ec2-windows"
  source = "../../modules/ecs-ec2-windows"

  # Required: existing Windows ECS cluster and networking
  ecs_cluster_name   = var.ecs_cluster_name
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  # Required: Windows image tag and Coralogix
  image_version    = var.image_version
  coralogix_region = var.coralogix_region
  api_key          = var.api_key

  # Optional
  default_application_name = var.default_application_name
  default_subsystem_name   = var.default_subsystem_name
  cpu                      = var.cpu
  memory                   = var.memory
  health_check_enabled     = var.health_check_enabled
}
