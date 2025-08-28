terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "test_scenario" {
  description = "Which test scenario to run"
  type        = string
  default     = "tail-sampling"
  validation {
    condition     = contains(["tail-sampling", "central-cluster", "external-role"], var.test_scenario)
    error_message = "test_scenario must be one of: tail-sampling, central-cluster, external-role"
  }
}

# Test: Tail Sampling Deployment
module "otel_tail_sampling" {
  count  = var.test_scenario == "tail-sampling" ? 1 : 0
  source = "../../modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = var.ecs_cluster_name
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
  security_group_ids   = var.security_group_ids
  deployment_type      = "tail-sampling"
  s3_config_bucket     = var.s3_config_bucket
  agent_s3_config_key  = var.agent_s3_config_key
  gateway_s3_config_key = var.gateway_s3_config_key
  image_version        = var.image_version
  coralogix_region     = var.coralogix_region
  api_key              = var.api_key

  # Optional parameters
  name_prefix = "tail"
  gateway_task_count = var.gateway_task_count
  memory            = var.memory
  default_application_name = var.default_application_name
  default_subsystem_name   = var.default_subsystem_name
  tags = var.tags
}

# Test: Central Cluster Deployment
module "otel_central_cluster" {
  count  = var.test_scenario == "central-cluster" ? 1 : 0
  source = "../../modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = var.ecs_cluster_name
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
  security_group_ids   = var.security_group_ids
  deployment_type      = "central-cluster"
  s3_config_bucket     = var.s3_config_bucket
  agent_s3_config_key  = var.agent_s3_config_key
  gateway_s3_config_key = var.gateway_s3_config_key
  receiver_s3_config_key = var.receiver_s3_config_key
  image_version        = var.image_version
  coralogix_region     = var.coralogix_region
  api_key              = var.api_key

  # Optional parameters
  name_prefix = "central"
  gateway_task_count = var.gateway_task_count
  receiver_task_count = var.receiver_task_count
  memory            = var.memory
  default_application_name = var.default_application_name
  default_subsystem_name   = var.default_subsystem_name
  tags = var.tags
}

# Test: External IAM Role Deployment
module "otel_external_role" {
  count  = var.test_scenario == "external-role" ? 1 : 0
  source = "../../modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = var.ecs_cluster_name
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
  security_group_ids   = var.security_group_ids
  deployment_type      = "tail-sampling"
  s3_config_bucket     = var.s3_config_bucket
  agent_s3_config_key  = var.agent_s3_config_key
  gateway_s3_config_key = var.gateway_s3_config_key
  image_version        = var.image_version
  coralogix_region     = var.coralogix_region
  api_key              = var.api_key

  # Optional parameters
  name_prefix = "external"
  gateway_task_count = var.gateway_task_count
  memory            = var.memory
  default_application_name = var.default_application_name
  default_subsystem_name   = var.default_subsystem_name
  task_execution_role_arn = var.external_task_execution_role_arn
  tags = var.tags
}
 
