module "otel_ecs_ec2_tail_sampling" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = "test-lab-cluster"
  vpc_id               = "vpc-12345678"
  subnet_ids           = ["subnet-12345678", "subnet-87654321"]
  security_group_ids   = ["sg-12345678"]
  deployment_type      = "tail-sampling"
  s3_config_bucket     = "my-otel-configs-bucket"
  agent_s3_config_key  = "configs/agent-config.yaml"
  gateway_s3_config_key = "configs/gateway-config.yaml"
  image_version        = "v0.5.1"
  coralogix_region     = "EU1"
  api_key              = "1234567890_DUMMY_API_KEY"

  # Optional parameters with sensible defaults
  name_prefix = "otel"
  gateway_task_count = 1
  memory            = 1024
  default_application_name = "YOUR_APPLICATION_NAME"
  default_subsystem_name   = "YOUR_SUBSYSTEM_NAME"
  health_check_enabled      = true
  health_check_interval     = 30
  health_check_timeout      = 5
  health_check_retries      = 3
  health_check_start_period = 10
  tags = {
    Environment = "test"
    Project     = "otel-tail-sampling"
  }
}
