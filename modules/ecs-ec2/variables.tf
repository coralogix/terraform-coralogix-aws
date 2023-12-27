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
  description = "The region of the Coralogix endpoint domain: [Europe, Europe2, India, Singapore, US, US2, Custom]. If \"Custom\" then __custom_domain__ parameter must be specified."
  type        = string
  validation {
    condition     = can(regex("^(europe|europe2|india|singapore|us|us2|custom)$", lower(var.coralogix_region)))
    error_message = "Must be one of [Europe, Europe2, India, Singapore, US, US2, Custom]"
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

variable "api_key" {
  description = "The Send-Your-Data API key for your Coralogix account. See: https://coralogix.com/docs/send-your-data-api-key/"
  type        = string
  sensitive   = true
}

variable "metrics" {
  type        = bool
  description = "Toggles Metrics collection of ECS Task resource usage (such as CPU, memory, network, and disk) and publishes to Coralogix. Default __'false'__ . Note that Logs and Traces are always enabled."
  default     = false
}

variable "otel_config_file" {
  type        = string
  description = "File path to a custom opentelemetry configuration file. Defaults to an embedded configuration."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Resurce tags"
  default     = null
}

variable "task_definition_arn" {
  type = string
  description = "Existing Coralogix OTEL task definition ARN"
  default = null
}
