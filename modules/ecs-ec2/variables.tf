variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate."
  type        = string
}

variable "config_source" {
  description = "Reserved for UI compatibility. Only 's3' is supported. Omit when using the module directly."
  type        = string
  default     = "s3"
  validation {
    condition     = var.config_source == "s3"
    error_message = "config_source must be 's3'. Use config from Coralogix UI or the integration chart."
  }
}

variable "s3_config_bucket" {
  description = "S3 bucket name containing the OpenTelemetry configuration file. Required when the module creates the task definition (task_definition_arn is null). Ignored in service-only mode (task_definition_arn set)."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn != null || var.s3_config_bucket != null
    error_message = "s3_config_bucket is required when task_definition_arn is null (module creates the task definition)."
  }
}

variable "s3_config_key" {
  description = "S3 object key (file path) for the configuration file. Example: configs/otel-config.yaml. Required when the module creates the task definition. Ignored in service-only mode."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn != null || var.s3_config_key != null
    error_message = "s3_config_key is required when task_definition_arn is null (module creates the task definition)."
  }
}

variable "image_version" {
  description = "The Coralogix Open Telemetry Distribution Image Version/Tag. Required when module creates the task definition. Ignored in service-only mode."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn != null || var.image_version != null
    error_message = "image_version is required when task_definition_arn is null (module creates the task definition)."
  }
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
  description = "The region of the Coralogix endpoint domain: [EU1|EU2|AP1|AP2|AP3|US1|US2|custom]. Required when module creates the task definition. Ignored in service-only mode."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn != null || (var.coralogix_region != null && can(regex("^(EU1|EU2|AP1|AP2|AP3|US1|US2|custom)$", var.coralogix_region)))
    error_message = "coralogix_region is required when task_definition_arn is null. Must be one of [EU1|EU2|AP1|AP2|AP3|US1|US2|custom]."
  }
}

variable "custom_domain" {
  description = "[Optional] Coralogix custom domain, e.g. \"private.coralogix.com\" Private Link domain. If specified, overrides the public domain corresponding to the __coralogix_region__ parameter."
  type        = string
  default     = null
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
    condition     = var.task_definition_arn != null || (var.use_api_key_secret ? var.api_key == null : var.api_key != null)
    error_message = "api_key must be provided unless use_api_key_secret is true (when module creates the task definition)."
  }
}

variable "api_key_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the API key"
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn != null || (var.use_api_key_secret ? var.api_key_secret_arn != null : var.api_key_secret_arn == null)
    error_message = "api_key_secret_arn must be set when use_api_key_secret is true (when module creates the task definition)."
  }
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role. When not provided and the module creates the task definition, an auto-created role with S3 and optional Secrets Manager access is used. In service-only mode (task_definition_arn set), this must be explicitly null—roles live on the task definition, not the service."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn == null || var.task_execution_role_arn == null
    error_message = "In service-only mode (task_definition_arn set), task_execution_role_arn must be null. Roles are defined on the task definition; the service does not accept role ARNs. Set task_execution_role_arn = null explicitly."
  }
}

variable "task_role_arn" {
  description = "ARN of the task role (IAM role) that the container can assume. When not provided and the module creates the task definition, an auto-created role with S3 read permissions is used. In service-only mode (task_definition_arn set), this must be explicitly null—roles live on the task definition, not the service."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn == null || var.task_role_arn == null
    error_message = "In service-only mode (task_definition_arn set), task_role_arn must be null. Roles are defined on the task definition; the service does not accept role ARNs. Set task_role_arn = null explicitly."
  }
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = null
}

variable "task_definition_arn" {
  type        = string
  description = "Existing Coralogix OTEL task definition ARN. When set, the module operates in service-only mode: it creates only the ECS service and does not manage config, command, or IAM. S3 inputs are ignored; task_execution_role_arn and task_role_arn must be null."
  default     = null
}

variable "health_check_enabled" {
  description = "Enable ECS container health check for the OTEL agent container. Requires OTEL collector image version v0.4.2 or later."
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
