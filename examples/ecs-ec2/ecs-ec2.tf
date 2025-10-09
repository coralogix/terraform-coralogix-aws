module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  # Required parameters
  ecs_cluster_name         = "test-lab-cluster"
  image_version            = "v0.5.1"
  coralogix_region         = "EU1"
  api_key                  = "1234567890_DUMMY_API_KEY"

  # Optional parameters with sensible defaults
  enable_head_sampler  = true
  sampling_percentage  = 10
  sampler_mode         = "proportional"
  enable_span_metrics  = true
  enable_traces_db     = true
  health_check_enabled = true

} 