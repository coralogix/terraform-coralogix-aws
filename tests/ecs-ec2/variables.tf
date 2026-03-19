variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "ecs-cluster"
}

variable "image" {
  description = "Docker image for the coralogix-otel-collector"
  type        = string
  default     = "coralogixrepo/coralogix-otel-collector"
}

variable "image_version" {
  description = "Version tag for the coralogix-otel-collector image"
  type        = string
  default     = "v0.5.10"
}

variable "coralogix_region" {
  description = "Coralogix region for data ingestion"
  type        = string
  default     = "EU1"
}

variable "custom_domain" {
  description = "Optional custom domain for Coralogix endpoint"
  type        = string
  default     = null
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
  default     = "cxtp_CoralogixSendYourDataKey"
}

variable "s3_config_bucket" {
  description = "S3 bucket name containing the configuration file. Required when task_definition_arn is null."
  type        = string
  default     = "placeholder-bucket"
}

variable "s3_config_key" {
  description = "S3 object key (file path) for the configuration file. Required when task_definition_arn is null."
  type        = string
  default     = "configs/otel-config.yaml"
}

variable "task_definition_arn" {
  description = "Existing task definition ARN. When set, service-only mode: module creates only the ECS service."
  type        = string
  default     = null
}

variable "task_execution_role_arn" {
  description = "ARN of the IAM role that the Amazon ECS container agent assumes"
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "ARN of the task role (IAM role) that the container can assume at runtime"
  type        = string
  default     = null
}

variable "health_check_enabled" {
  description = "Enable ECS container health check for the OTEL agent"
  type        = bool
  default     = false
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_retries" {
  description = "Health check retries"
  type        = number
  default     = 3
}

variable "memory" {
  description = "Task memory in MiB"
  type        = number
  default     = 256
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = null
}
