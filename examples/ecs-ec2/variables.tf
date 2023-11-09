variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate."
  type        = string
}

variable "image_version" {
  description = "The Coralogix Open Telemetry Distribution Image Version/Tag. Defaults to \"latest\". See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags"
  type        = string
  default     = "latest"
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task. Note that your cluster must have sufficient memory available to support the given value."
  type        = number
  default     = 256
}

variable "coralogix_region" {
  description = "The Coralogix location region, [Europe, Europe2, India, Singapore, US, US2]"
  type        = string
}

variable "default_application_name" {
  description = "The default Coralogix Application name."
  type        = string
}

variable "default_subsystem_name" {
  description = "The default Coralogix Subsystem name."
  type        = string
  default     = "default"
}

variable "private_key" {
  description = "The Coralogix Send-Your-Data API key for your Coralogix account."
  type        = string
  sensitive   = true
}

variable "metrics" {
  type        = bool
  description = "If true, cadivisor will be deployed on each node to collect metrics"
  default     = false
}
