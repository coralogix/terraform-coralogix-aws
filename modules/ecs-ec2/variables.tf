variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate."
  type        = string
}

variable "image_version" {
  description = "The Coralogix Open Telemetry Distribution Image Version/Tag. See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags"
  type        = string
}

variable "image" {
  description = "The OpenTelemetry Collector Image to use. Should accept default unless advised by Coralogix support."
  type        = string
  default     = "coralogixrepo/coralogix-otel-collector"
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task. Note that your cluster must have sufficient memory available to support the given value. Minimum __256__ MiB. CPU Units will be allocated directly proportional to Memory."
  type        = number
  default     = 256
}

variable "coralogix_region" {
  description = "The region of the Coralogix endpoint domain: [EU1|EU2|AP1|AP2|AP3|US1|US2|custom]. If \"custom\" then __custom_domain__ parameter must be specified."
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

variable "default_application_name" {
  description = "The default Coralogix Application name."
  type        = string
  validation {
    condition     = length(var.default_application_name) >= 1 && length(var.default_application_name) <= 64
    error_message = "The Default Application Name length should be within 1 and 64 characters"
  }
}

variable "default_subsystem_name" {
  description = "The default Coralogix Subsystem name."
  type        = string
  validation {
    condition     = length(var.default_subsystem_name) >= 1 && length(var.default_subsystem_name) <= 64
    error_message = "The Default Subsystem Name length should be within 1 and 64 characters"
  }
}

variable "use_api_key_secret" {
  description = "Whether to use API key stored in AWS Secrets Manager"
  type        = bool
  default     = false
}

variable "api_key" {
  description = "The Send-Your-Data API key for your Coralogix account. See: https://coralogix.com/docs/send-your-data-api-key/"
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition     = var.use_api_key_secret ? var.api_key == null : var.api_key != null
    error_message = "Check api_key variable. It must be provided unless use_api_key_secret is true."
  }
}

variable "api_key_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the API key"
  type        = string
  default     = null

  validation {
    condition     = var.use_api_key_secret ? var.api_key_secret_arn != null : var.api_key_secret_arn == null
    error_message = "Check api_key_secret_arn variable. If use_api_key_secret is true, it must be populated. If not, it must be null"
  }
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

  validation {
    condition     = var.use_custom_config_parameter_store ? var.custom_config_parameter_store_name != null : true
    error_message = "Check custom_config_parameter_store_name variable. It must be provided if use_custom_config_parameter_store is true."
  }
}

variable "otel_config_file" {
  type        = string
  description = "File path to a custom opentelemetry configuration file. Defaults to an embedded configuration."
  default     = null

  validation {
    condition     = var.use_custom_config_parameter_store ? var.otel_config_file == null : true
    error_message = "Check otel_config_file variable. It must be null if using a Custom Configuration from a Parameter Store"
  }
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
  type        = string
  default     = null

  validation {
    condition     = (var.api_key_secret_arn != null || var.custom_config_parameter_store_name != null) ? var.task_execution_role_arn != null : true
    error_message = "task_execution_role_arn must be provided if using a API Key Secret or a Custom Configuration from a Parameter Store"
  }
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
  description = "Enable or disable head sampling for traces. When enabled, sampling decisions are made at the collection point before any processing occurs."
  type        = bool
  default     = true
}

variable "sampling_percentage" {
  description = "The percentage of traces to sample (0-100). A value of 100 means all traces will be sampled."
  type        = number
  default     = 10
  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

variable "sampler_mode" {
  description = "The sampling mode to use (proportional, equalizing, or hash_seed)."
  type        = string
  default     = "proportional"
  validation {
    condition     = contains(["proportional", "equalizing", "hash_seed"], var.sampler_mode)
    error_message = "Sampler mode must be one of: proportional, equalizing, hash_seed."
  }
}
