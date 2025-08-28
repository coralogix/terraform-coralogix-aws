variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ECS services will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the ECS services will be deployed"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ECS services"
  type        = list(string)
}

variable "deployment_type" {
  description = "Deployment type: 'tail-sampling' or 'central-cluster'"
  type        = string
  validation {
    condition     = contains(["tail-sampling", "central-cluster"], var.deployment_type)
    error_message = "Deployment type must be one of: tail-sampling, central-cluster."
  }
}

variable "s3_config_bucket" {
  description = "S3 bucket name containing the OpenTelemetry configuration files"
  type        = string
}

variable "agent_s3_config_key" {
  description = "S3 object key for the Agent configuration file"
  type        = string
  default     = "configs/agent-config.yaml"
}

variable "gateway_s3_config_key" {
  description = "S3 object key for the Gateway configuration file"
  type        = string
  default     = "configs/gateway-config.yaml"
}

variable "receiver_s3_config_key" {
  description = "S3 object key for the Receiver configuration file"
  type        = string
  default     = "configs/receiver-config.yaml"
}

variable "image_version" {
  description = "The Coralogix Open Telemetry Distribution Image Version/Tag. See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags. Required when custom_image is not provided."
  type        = string
  default     = "v0.5.0"
}

variable "custom_image" {
  description = "Custom OpenTelemetry Collector Image to use (e.g., 'my-registry.com/custom-otel-collector:latest'). If provided, this overrides image_version."
  type        = string
  default     = null
}

variable "coralogix_region" {
  description = "The region of the Coralogix endpoint domain"
  type        = string
  validation {
    condition     = can(regex("^(EU1|EU2|AP1|AP2|AP3|US1|US2|custom)$", var.coralogix_region))
    error_message = "Must be one of [EU1|EU2|AP1|AP2|AP3|US1|US2|custom]."
  }
}

variable "custom_domain" {
  description = "[Optional] Coralogix custom domain, e.g. \"private.coralogix.com\" Private Link domain. If specified, overrides the public domain corresponding to the __coralogix_region__ parameter."
  type        = string
  default     = null
}

variable "api_key" {
  description = "The Send-Your-Data API key for your Coralogix account"
  type        = string
  sensitive   = true
}

variable "name_prefix" {
  description = "Prefix for resource names to avoid conflicts"
  type        = string
  default     = "otel"
}

variable "gateway_task_count" {
  description = "Number of Gateway tasks to run"
  type        = number
  default     = 1
}

variable "receiver_task_count" {
  description = "Number of Receiver tasks to run"
  type        = number
  default     = 2
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task"
  type        = number
  default     = 1024
}

variable "default_application_name" {
  description = "The default Coralogix Application name"
  type        = string
}

variable "default_subsystem_name" {
  description = "The default Coralogix Subsystem name"
  type        = string
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}
