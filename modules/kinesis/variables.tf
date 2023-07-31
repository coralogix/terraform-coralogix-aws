variable "coralogix_region" {
  description = "The Coralogix location region, possible options are [Europe, Europe2, India, Singapore, US, Custom]"
  type        = string
  validation {
    condition     = contains(["Europe", "Europe2", "India", "Singapore", "US", "US2", "Custom"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [Europe, Europe2, India, Singapore, US, US2, Custom]."
  }
  default = "Europe"
}

variable "custom_url" {
  description = "Your Custom URL for the Coralogix account."
  type        = string
  default     = ""
}

variable "private_key" {
  description = "The Coralogix private key which is used to validate your authenticity"
  type        = string
  sensitive   = true
}

variable "application_name" {
  description = "The name of your application"
  type        = string
}

variable "subsystem_name" {
  description = "The subsystem name of your application"
  type        = string
  default     = ""
}

variable "kinesis_stream_name" {
  description = "The kinesis stream name"
  type        = string
  default     = ""
}

variable "package_name" {
  description = "The name of the package to use for the function"
  type        = string
  default     = "kinesis"
}

variable "newline_pattern" {
  description = "The pattern for lines splitting"
  type        = string
  default     = "(?:\\r\\n|\\r|\\n)"
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

variable "architecture" {
  description = "Lambda function architecture"
  type        = string
  default     = "x86_64"
}

variable "notification_email" {
  description = "Failure notification email address"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "ssm_enable" {
  description = "Use SSM for the private key True/False"
  type        = string
  default     = "False"
}

variable "layer_arn" {
  description = "Coralogix SSM Layer ARN"
  type        = string
  default     = ""
}
