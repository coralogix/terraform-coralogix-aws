module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name      = var.ecs_cluster_name
  image_version         = var.image_version
  coralogix_region      = var.coralogix_region
  api_key               = var.api_key
  s3_config_bucket      = var.s3_config_bucket
  s3_config_key         = var.s3_config_key
  health_check_enabled  = var.health_check_enabled
  memory                = var.memory
  tags                  = var.tags
}
