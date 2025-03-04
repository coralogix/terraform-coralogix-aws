variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "image" {
  description = "Docker image for the coralogix-otel-collector"
  type        = string
  default     = "coralogixrepo/coralogix-otel-collector"
}

variable "image_version" {
  description = "Version tag for the coralogix-otel-collector image"
  type        = string
}

variable "coralogix_region" {
  description = "Coralogix region for data ingestion"
  type        = string
}

variable "custom_domain" {
  description = "Optional custom domain for Coralogix endpoint"
  type        = string
  default     = null
}

variable "default_application_name" {
  description = "Default application name for Coralogix logs"
  type        = string
  default     = "ecs-ec2-tf-test"
}

variable "default_subsystem_name" {
  description = "Default subsystem name for Coralogix logs"
  type        = string
  default     = "ecs-ec2-tf-test"
}

variable "use_api_key_secret" {
  description = "Whether to use API key from AWS Secrets Manager"
  type        = bool
  default     = false
}

variable "api_key_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the API key"
  type        = string
  default     = null
}

variable "api_key" {
  description = "Coralogix API key for data ingestion"
  type        = string
  sensitive   = true
  default     = null
}

variable "use_custom_config_parameter_store" {
  description = "Whether to use a custom config from Parameter Store"
  type        = bool
  default     = false
}

variable "custom_config_parameter_store_name" {
  description = "Name of the Parameter Store parameter containing the custom config"
  type        = string
  default     = null
}

variable "otel_config_file" {
  description = "Path to a custom OpenTelemetry collector config file"
  type        = string
  default     = null
}

variable "task_execution_role_arn" {
  description = "ARN of the IAM role that the Amazon ECS container agent assumes"
  type        = string
  default     = null
}
