variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate."
  type        = string
}

variable "image_version" {
  description = "The Coralogix Open Telemetry Distribution Image Version/Tag. See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags"
  type        = string
  default     = "v0.4.2"
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task"
  type        = number
  default     = 256
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
  description = "Optional Coralogix custom domain"
  type        = string
  default     = null
}

variable "default_application_name" {
  description = "The default Coralogix Application name"
  type        = string
}

variable "default_subsystem_name" {
  description = "The default Coralogix Subsystem name"
  type        = string
}

variable "use_api_key_secret" {
  description = "Whether to use API key stored in AWS Secrets Manager"
  type        = bool
  default     = false
}

variable "api_key" {
  description = "The Send-Your-Data API key for your Coralogix account"
  type        = string
  sensitive   = true
  default     = null
}

variable "api_key_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the API key"
  type        = string
  default     = null
}

variable "use_custom_config_parameter_store" {
  description = "Whether to use a custom configuration from a Parameter Store"
  type        = bool
  default     = false
}

variable "custom_config_parameter_store_name" {
  description = "Name of the Parameter Store parameter containing the OTEL configuration. If not provided, default configuration will be used"
  type        = string
  default     = null
}

variable "otel_config_file" {
  type        = string
  description = "File path to a custom opentelemetry configuration file. Defaults to an embedded configuration"
  default     = null
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = null
}

variable "task_definition_arn" {
  type        = string
  description = "Existing Coralogix OTEL task definition ARN"
  default     = null
}

variable "enable_head_sampler" {
  description = "Enable or disable head sampling for traces"
  type        = bool
  default     = true
}

variable "sampling_percentage" {
  description = "The percentage of traces to sample (0-100)"
  type        = number
  default     = 10
  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

variable "sampler_mode" {
  description = "The sampling mode to use (proportional, equalizing, or hash_seed)"
  type        = string
  default     = "proportional"
  validation {
    condition     = contains(["proportional", "equalizing", "hash_seed"], var.sampler_mode)
    error_message = "Sampler mode must be one of: proportional, equalizing, hash_seed."
  }
}

variable "enable_span_metrics" {
  description = "Enable or disable span metrics generation"
  type        = bool
  default     = true
}

variable "enable_traces_db" {
  description = "Enable or disable database traces"
  type        = bool
  default     = false
}

variable "health_check_enabled" {
  description = "Enable ECS container health check for the OTEL agent container"
  type        = bool
  default     = false
}

variable "health_check_interval" {
  description = "Health check interval in seconds. Only used if health_check_enabled is true."
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds. Only used if health_check_enabled is true."
  type        = number
  default     = 5
}

variable "health_check_retries" {
  description = "Health check retries. Only used if health_check_enabled is true."
  type        = number
  default     = 3
}

variable "health_check_start_period" {
  description = "Health check start period in seconds. Only used if health_check_enabled is true."
  type        = number
  default     = 10
} 