variable "coralogix_region" {
  type    = string
  default = "Europe"
}

variable "ecs_cluster_name" {
  type    = string
  default = "test-lab-cluster"
}

variable "api_key" {
  type    = string
  default = "1234567890_DUMMY_API_KEY"
}

variable "custom_domain" {
  type    = string
  default = null
}

variable "otel_config_file" {
  description = "[Optional] Path to a custom opentelemetry configuration file"
  type        = string
  default     = null
}

variable "metrics" {
  type    = bool
  default = false
}
