variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ecs_cluster_name" {
  description = "Name of the existing Windows ECS cluster"
  type        = string
  default     = "ecs-ec2-windows-testing-cluster"
}

variable "subnet_ids" {
  description = "Subnet IDs for the ECS service. If empty, default VPC subnets are used (for plan/validate)."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for the ECS service. If empty, default VPC default SG is used (for plan/validate)."
  type        = list(string)
  default     = []
}

variable "service_discovery_registry_arn" {
  description = "Cloud Map service ARN so the agent registers (e.g. agent.otel.local). Optional; set so other tasks can reach the agent."
  type        = string
  default     = null
}

variable "image" {
  description = "Docker image for the coralogix-otel-collector (Windows)"
  type        = string
  default     = "coralogixrepo/coralogix-otel-collector"
}

variable "image_version" {
  description = "Version tag for the Windows coralogix-otel-collector image"
  type        = string
  default     = "v0.5.11-windowsserver-2022"
}

variable "cpu" {
  description = "Task CPU units"
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Task memory (MiB)"
  type        = number
  default     = 2048
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

variable "default_application_name" {
  description = "Default application name for Coralogix logs"
  type        = string
  default     = "otel"
}

variable "default_subsystem_name" {
  description = "Default subsystem name for Coralogix logs"
  type        = string
  default     = "ecs-ec2-windows-tf-test"
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

variable "config_source" {
  description = "Configuration source: 'template', 's3', 'parameter-store'"
  type        = string
  default     = "template"
}

variable "s3_config_bucket" {
  description = "S3 bucket name when config_source is 's3'"
  type        = string
  default     = null
}

variable "s3_config_key" {
  description = "S3 object key when config_source is 's3'"
  type        = string
  default     = null
}

variable "custom_config_parameter_store_name" {
  description = "Parameter Store parameter name when config_source is 'parameter-store'"
  type        = string
  default     = null
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role (required for parameter-store or Secrets Manager)"
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "ARN of the task role for runtime (e.g. S3 config)"
  type        = string
  default     = null
}

variable "health_check_enabled" {
  description = "Enable ECS container health check"
  type        = bool
  default     = false
}
