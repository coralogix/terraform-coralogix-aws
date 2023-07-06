variable "coralogix_region" {
  description = "The Coralogix location region, possible options are [Europe, Europe2, India, Singapore, US]"
  type        = string
  validation {
    condition     = contains(["ireland", "India", "Singapore", "US", "Custom"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [ireland, India, Singapore, US, Custom]."
  }
  default = "ireland"
}

variable "custom_url" {
  description = "Your Custom URL for the Coralogix account."
  type        = string
  default = null
}

variable "private_key" {
  description = "The Coralogix private key which is used to validate your authenticity"
  type        = string
  sensitive   = true
}

variable "ssm_enable" {
  description = "Use SSM for the private key True/False"
  type        = string
}

variable "layer_arn" {
  description = "Coralogix SSM Layer ARN"
  type        = string
}

variable "application_name" {
  description = "The name of your application"
  type        = string
}

variable "subsystem_name" {
  description = "The subsystem name of your application"
  type        = string
}

variable "architecture" {
  description = "Lambda function architecture"
  type        = string
  default     = "x86_64"
}

variable "memory_size" {
  description = "Lambda function memory limit"
  type        = number
  default     = 1024
}

variable "timeout" {
  description = "Lambda function timeout limit"
  type        = number
  default     = 300
}

variable "notification_email" {
  description = "Failure notification email address"
  type        = string
}


variable "msk_cluster_arn" {
  description = "The ARN of the Amazon MSK Kafka cluster"
  type        = string
}

variable "topic" {
  description = "The name of the Kafka topic used to store records in your Kafka cluster"
  type        = string
}

variable "msk_stream" {
  description = "AWS MSK delivery stream name"
  type        = string
}
