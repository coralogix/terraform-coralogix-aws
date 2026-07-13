variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate."
  type        = string
}

variable "config_source" {
  description = "Reserved for UI compatibility. Keep this set to 's3'. Supervised mode uses embedded configs when S3 paths are omitted."
  type        = string
  default     = "s3"
  validation {
    condition     = var.config_source == "s3"
    error_message = "config_source must be 's3'. Use config from Coralogix UI or the integration chart."
  }
}

variable "supervisor_enabled" {
  description = "Whether to run the Collector through the Supervisor. When enabled, the supervised CDOT image and embedded configs are used unless S3 paths are provided."
  type        = bool
  default     = false
}

variable "s3_config_bucket" {
  description = "S3 bucket containing collector and optional Supervisor configurations. Required in collector mode. In supervised mode, omit it to use embedded configs. Ignored in service-only mode."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn != null || var.supervisor_enabled || try(trimspace(var.s3_config_bucket) != "", false)
    error_message = "s3_config_bucket is required in collector mode when the module creates the task definition."
  }
}

variable "s3_config_key" {
  description = "S3 object key for the collector configuration. Required in collector mode. In supervised mode, omit it to use the embedded collector config. Ignored in service-only mode."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn != null || var.supervisor_enabled || try(trimspace(var.s3_config_key) != "", false)
    error_message = "s3_config_key is required in collector mode when the module creates the task definition."
  }
}

variable "s3_supervisor_config_key" {
  description = "Optional S3 object key for the Supervisor configuration. Used only in supervised mode when s3_config_bucket is also set. When omitted, the embedded Supervisor config is used."
  type        = string
  default     = null
}

variable "image_version" {
  description = "The standard CDOT image version used in collector mode. Required in collector mode when the module creates the task definition."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn != null || var.supervisor_enabled || try(trimspace(var.image_version) != "", false)
    error_message = "image_version is required in collector mode when the module creates the task definition."
  }
}

variable "image" {
  description = "The OpenTelemetry Collector image used in collector mode. Keep the default unless advised by Coralogix support."
  type        = string
  default     = "coralogixrepo/coralogix-otel-collector"
}

variable "supervised_image_repository" {
  description = "The supervised CDOT image repository used in supervised mode."
  type        = string
  default     = "cgx.jfrog.io/coralogix-docker-images/coralogix-otel-supervised-cdot"

  validation {
    condition     = trimspace(var.supervised_image_repository) != ""
    error_message = "supervised_image_repository must not be empty."
  }
}

variable "supervised_image_version" {
  description = "The supervised CDOT image version used in supervised mode."
  type        = string
  default     = "v0.10.0"

  validation {
    condition     = trimspace(var.supervised_image_version) != ""
    error_message = "supervised_image_version must not be empty."
  }
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

variable "api_key_secret_kms_key_arn" {
  description = "KMS key ARN used to encrypt the Secrets Manager secret. When set, the module skips DescribeSecret/DescribeKey lookups—use this when the deploy role cannot access secret metadata (e.g. restricted IAM). Omit when the secret uses the default aws/secretsmanager key."
  type        = string
  default     = null

  validation {
    condition     = var.api_key_secret_kms_key_arn == null || var.api_key_secret_kms_key_arn != ""
    error_message = "api_key_secret_kms_key_arn must be null or a non-empty KMS key ARN."
  }
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role. When not provided and the module creates the task definition, an auto-created role with the standard ECS execution policy and optional Secrets Manager access is used. In service-only mode, this must be null."
  type        = string
  default     = null

  validation {
    condition     = var.task_definition_arn == null || var.task_execution_role_arn == null
    error_message = "In service-only mode (task_definition_arn set), task_execution_role_arn must be null. Roles are defined on the task definition; the service does not accept role ARNs. Set task_execution_role_arn = null explicitly."
  }
}

variable "task_role_arn" {
  description = "ARN of the task role that the containers can assume. When an S3 config is selected and this is not provided, the module creates a role with S3 read permissions. In service-only mode, this must be null."
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
