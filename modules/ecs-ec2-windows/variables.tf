variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Must be a Windows EC2 cluster (WINDOWS_SERVER_2022_CORE)."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ECS service (awsvpc network mode). Use private subnets where your Windows ECS container instances run."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ECS service (awsvpc network mode). Must allow outbound traffic and any required agent ports (e.g. OTLP 4317)."
  type        = list(string)
}

variable "service_discovery_registry_arn" {
  description = "ARN of an AWS Cloud Map service for service discovery. When set, the ECS service registers with it so other tasks can reach the agent via DNS (e.g. agent.otel.local:4317). Use the same namespace/service as in telemetry-shippers (otel.local / agent) so those tasks can connect."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for the OTEL agent. If null, a log group is created automatically."
  type        = string
  default     = null
}

variable "cloudwatch_log_retention_days" {
  description = "Retention in days for the created CloudWatch log group. Only used when cloudwatch_log_group_name is null."
  type        = number
  default     = 7
}

variable "config_source" {
  description = "Select the configuration source for OpenTelemetry Collector. Options: 'template' (default), 's3', 'parameter-store'"
  type        = string
  default     = "template"
  validation {
    condition     = contains(["template", "s3", "parameter-store"], var.config_source)
    error_message = "Config source must be one of: template, s3, parameter-store."
  }
}

variable "s3_config_bucket" {
  description = "S3 bucket name containing the configuration file. Required when config_source is 's3'."
  type        = string
  default     = null
}

variable "s3_config_key" {
  description = "S3 object key (file path) for the configuration file. Required when config_source is 's3'."
  type        = string
  default     = null

  validation {
    condition     = (var.config_source == "s3") ? (var.s3_config_bucket != null && var.s3_config_key != null) : true
    error_message = "Both s3_config_bucket and s3_config_key must be provided when config_source is 's3'."
  }
}

variable "image" {
  description = "The OpenTelemetry Collector image repository. For Windows use the Windows image; default is coralogixrepo/coralogix-otel-collector (set image_version to a Windows tag, e.g. v0.5.11-windowsserver-2022)."
  type        = string
  default     = "coralogixrepo/coralogix-otel-collector"
}

variable "image_version" {
  description = "The Coralogix OTEL Collector image tag. For Windows ECS use a Windows Server tag, e.g. v0.5.11-windowsserver-2022. See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task (1024 = 1 vCPU). Windows tasks typically use 1024 or more."
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Memory (MiB) for the task. Windows OTEL agent typically uses 2048."
  type        = number
  default     = 2048
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
  default     = "otel"
}

variable "default_subsystem_name" {
  description = "The default Coralogix Subsystem name."
  type        = string
  default     = "ecs-ec2-windows"
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
  description = "Name of the Parameter Store parameter containing the OTEL configuration. Required when config_source is 'parameter-store'"
  type        = string
  default     = null

  validation {
    condition     = (var.config_source == "parameter-store") ? var.custom_config_parameter_store_name != null : true
    error_message = "custom_config_parameter_store_name must be provided when config_source is 'parameter-store'."
  }
}

variable "task_execution_role_arn" {
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. When using S3 configuration, if not provided, an auto-created role with S3 read permissions will be used."
  type        = string
  default     = null

  validation {
    condition     = (var.use_api_key_secret == true || var.config_source == "parameter-store") ? var.task_execution_role_arn != null : true
    error_message = "task_execution_role_arn must be provided if using API Key Secret or Parameter Store config"
  }
}

variable "task_role_arn" {
  description = "ARN of the task role (IAM role) that the container can assume. If not provided, the task will run without a task role (null). This is separate from the execution role which is used by ECS to pull images and retrieve secrets."
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

variable "enable_span_metrics" {
  description = "Enable or disable the spanmetrics processor and pipeline. When enabled (default), span metrics will be generated from traces."
  type        = bool
  default     = true
}

variable "enable_traces_db" {
  description = "Enable or disable the traces/db pipeline for database operation metrics. When enabled, database operation metrics will be generated. Note: This feature requires spanmetrics to be enabled."
  type        = bool
  default     = false
}

variable "health_check_enabled" {
  description = "Enable ECS container health check for the OTEL agent container, Requires OTEL collector image version v0.4.2 or later."
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
