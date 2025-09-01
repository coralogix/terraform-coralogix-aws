variable "ecs_cluster_name" {
  description = "Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to add to resource names to make them unique"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID for CloudMap namespace and ECS services"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS services"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for ECS services"
  type        = list(string)
}

variable "deployment_type" {
  description = "Deployment type: 'tail-sampling' or 'central-cluster'"
  type        = string
  validation {
    condition     = contains(["tail-sampling", "central-cluster"], var.deployment_type)
    error_message = "Deployment type must be one of: tail-sampling, central-cluster."
  }
}

variable "s3_config_bucket" {
  description = "S3 bucket name containing the configuration files"
  type        = string
}

variable "agent_s3_config_key" {
  description = "S3 object key for the Agent configuration file (required for tail-sampling deployment)"
  type        = string
  default     = null

  validation {
    condition     = (var.deployment_type == "tail-sampling") ? (var.agent_s3_config_key != null) : true
    error_message = "agent_s3_config_key is required when deployment_type is 'tail-sampling'."
  }
}

variable "gateway_s3_config_key" {
  description = "S3 object key for the Gateway configuration file"
  type        = string
}

variable "receiver_s3_config_key" {
  description = "S3 object key for the Receiver configuration file (required for central-cluster deployment)"
  type        = string
  default     = null

  validation {
    condition     = (var.deployment_type == "central-cluster") ? (var.receiver_s3_config_key != null) : true
    error_message = "receiver_s3_config_key is required when deployment_type is 'central-cluster'."
  }
}

variable "image_version" {
  description = "The Coralogix Distribution OpenTelemetry Image Version/Tag. See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags. Required when custom_image is not provided."
  type        = string
  default     = null

  validation {
    condition     = var.custom_image != null || var.image_version != null
    error_message = "Either image_version or custom_image must be provided."
  }
}

variable "custom_image" {
  description = "Custom OpenTelemetry Collector Image to use (e.g., 'my-registry.com/custom-otel-collector:latest'). If provided, this overrides image_version."
  type        = string
  default     = null
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task. Note that your cluster must have sufficient memory available to support the given value. Minimum __256__ MiB. CPU Units will be allocated directly proportional to Memory."
  type        = number
  default     = 1024
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
  default     = "OTEL"
  validation {
    condition     = length(var.default_application_name) >= 1 && length(var.default_application_name) <= 64
    error_message = "The Default Application Name length should be within 1 and 64 characters"
  }
}

variable "default_subsystem_name" {
  description = "The default Coralogix Subsystem name."
  type        = string
  default     = "ECS-EC2"
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

variable "task_execution_role_arn" {
  description = "External IAM role ARN for task execution. If provided, this role will be used instead of creating new roles."
  type        = string
  default     = null
}

variable "gateway_task_count" {
  description = "Number of Gateway tasks to run"
  type        = number
  default     = 1
}

variable "receiver_task_count" {
  description = "Number of Receiver tasks to run (only for central-cluster deployment)"
  type        = number
  default     = 2
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
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
