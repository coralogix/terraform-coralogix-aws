variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the demonstration ECS Service, consisting of 1 Coralogix OTEL Collector and 1 sample app as Windows containers in the task. Supports EC2 Windows instances only, not Fargate."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to deploy the ECS Service into. Must be in the same VPC as the ECS Cluster."
  type        = list
}

variable "security_group_id" {
  description = "Security Group ID to deploy the ECS Service into. Must be in the same VPC as the ECS Cluster."
  type        = string
}

variable "coralogix_region" {
  description = "The region of the Coralogix endpoint domain: [Europe, Europe2, India, Singapore, US, US2, Custom]. If \"Custom\" then __custom_domain__ parameter must be specified."
  type        = string
  validation {
    condition     = can(regex("^(europe|europe2|india|singapore|us|us2|custom)$", lower(var.coralogix_region)))
    error_message = "Must be one of [Europe, Europe2, India, Singapore, US, US2, Custom]"
  }
}

variable "custom_domain" {
  description = "Optional Coralogix custom domain, e.g. \"private.coralogix.com\" Private Link domain. If specified, overrides the public domain corresponding to the __coralogix_region__ parameter."
  type        = string
  default     = null
}

variable "application_name" {
  description = "Optional Application name as Coralogix metadata."
  type        = string
  default     = "ECS-Windows-Demo"
  validation {
    condition     = length(var.application_name) >= 1 && length(var.application_name) <= 64
    error_message = "The Default Application Name length should be within 1 and 64 characters"
  }
}

variable "subsystem_name" {
  description = "Optional Subsystem name as Coralogix metadata."
  type        = string
  default     = "ECS-Windows-Demo"
  validation {
    condition     = length(var.subsystem_name) >= 1 && length(var.subsystem_name) <= 64
    error_message = "The Default Subsystem Name length should be within 1 and 64 characters"
  }
}

variable "otel_image" {
  description = "Optional Coralogix Open Telemetry distribution Windows image name and tag."
  type        = string
  default     = "coralogixrepo/coralogix-otel-collector:0.1.0-windowsserver-1809"
}

variable "app_image" {
  description = "Optional user-provided demo App as a Windows container image, to demonstrate collection of console logs and metrics. If omitted, defaults to a provided sample Windows logging app."
  type        = string
  default     = ""
}

variable "api_key" {
  description = "The Send-Your-Data API key for your Coralogix account. See: https://coralogix.com/docs/send-your-data-api-key/"
  type        = string
  sensitive   = true
}

variable "otel_config_file" {
  type        = string
  description = "Optional file path to a custom opentelemetry configuration file. Defaults to an embedded configuration."
  default     = null
}
