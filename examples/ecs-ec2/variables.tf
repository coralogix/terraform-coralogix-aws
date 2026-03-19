variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector."
  type        = string
}

variable "s3_config_bucket" {
  description = "S3 bucket containing the OTEL config. Use config from Coralogix UI or the integration chart."
  type        = string
}

variable "s3_config_key" {
  description = "S3 object key for the config file. Example: configs/otel-config.yaml"
  type        = string
}

variable "image_version" {
  description = "The Coralogix Open Telemetry Distribution Image Version/Tag."
  type        = string
  default     = "v0.5.10"
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

variable "api_key" {
  description = "The Send-Your-Data API key for your Coralogix account"
  type        = string
  sensitive   = true
}

variable "health_check_enabled" {
  description = "Enable ECS container health check for the OTEL agent container"
  type        = bool
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = null
}
