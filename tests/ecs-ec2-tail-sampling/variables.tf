variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster"
  type        = string
}


variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "s3_config_bucket" {
  description = "S3 bucket name containing the configuration files"
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
  description = "The Coralogix Distribution OpenTelemetry Image Version/Tag"
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
  default     = "EU2"
}

variable "api_key" {
  description = "The Send-Your-Data API key for your Coralogix account"
  type        = string
  sensitive   = true
}

variable "external_task_execution_role_arn" {
  description = "External IAM role ARN for testing external role functionality"
  type        = string
  default     = null
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
  default     = "OTEL"
}

variable "default_subsystem_name" {
  description = "The default Coralogix Subsystem name"
  type        = string
  default     = "ECS-EC2"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "test"
    Project     = "coralogix-otel"
    Test        = "true"
  }
}
