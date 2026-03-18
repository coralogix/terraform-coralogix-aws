variable "ecs_cluster_name" {
  description = "Name of the existing Windows ECS cluster (WINDOWS_SERVER_2022_CORE)."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs for the ECS service (awsvpc). Use private subnets where your Windows ECS instances run."
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "Security group IDs for the ECS service (awsvpc). Must allow outbound and agent ports (e.g. OTLP 4317)."
  type        = list(string)
  default     = null
}

variable "service_discovery_registry_arn" {
  description = "Cloud Map service ARN so the agent registers (e.g. agent.otel.local). Required for telemetrygen to reach the agent. From telemetry-shippers: terraform -chdir=path/to/telemetry-shippers/otel-ecs-ec2-windows/terraform output -raw service_discovery_agent_arn"
  type        = string
  default     = null
}

variable "image_version" {
  description = "OTEL Collector Windows image tag (e.g. v0.5.10-windowsserver-2022)."
  type        = string
  default     = "v0.5.10-windowsserver-2022"
}

variable "coralogix_region" {
  description = "Coralogix region (EU1, EU2, AP1, AP2, AP3, US1, US2, custom)."
  type        = string
  default     = null
  validation {
    condition     = var.coralogix_region == null || can(regex("^(EU1|EU2|AP1|AP2|AP3|US1|US2|custom)$", var.coralogix_region))
    error_message = "Must be one of [EU1|EU2|AP1|AP2|AP3|US1|US2|custom]."
  }
}

variable "api_key" {
  description = "Coralogix Send-Your-Data API key."
  type        = string
  sensitive   = true
  default     = null
}

variable "default_application_name" {
  description = "Default Coralogix application name."
  type        = string
  default     = "otel"
}

variable "default_subsystem_name" {
  description = "Default Coralogix subsystem name."
  type        = string
  default     = "ecs-ec2-windows"
}

variable "cpu" {
  description = "Task CPU units (1024 = 1 vCPU)."
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Task memory (MiB)."
  type        = number
  default     = 2048
}

variable "health_check_enabled" {
  description = "Enable ECS container health check for the OTEL agent."
  type        = bool
  default     = false
}
