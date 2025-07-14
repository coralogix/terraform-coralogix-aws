module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"
  
  # Required parameters
  ecs_cluster_name         = "test-lab-cluster"
  image_version            = "v0.4.2"
  coralogix_region         = "EU1"
  default_application_name = "YOUR_APPLICATION_NAME"
  default_subsystem_name   = "YOUR_SUBSYSTEM_NAME"
  api_key                  = "1234567890_DUMMY_API_KEY"
  
  # Optional parameters with sensible defaults
  enable_head_sampler      = true
  sampling_percentage      = 10
  sampler_mode            = "proportional"
  enable_span_metrics     = true
  enable_traces_db        = true
  health_check_enabled    = true
  
} 