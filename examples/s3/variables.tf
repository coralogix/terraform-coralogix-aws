variable "coralogix_region" {
  description = "The Coralogix location region, possible options are [Europe, Europe2, India, Singapore, US]"
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
  description = "Your Coralogix Send Your Data - API Key or incase you use pre created secret (created in AWS secret manager) put here the name of the secret that contains the Coralogix send your data key"
  type        = string
  sensitive   = true
}

variable "secret_manager_enabled" {
  description = "Set to true in case that you want to keep your Coralogix Send Your Data API Key as a secret in aws Secret Manager "
  type        = bool
  default     = false
}

variable "layer_arn" {
  description = "In case you are using Secret Manager This is the ARN of the Coralogix Security lambda Layer."
  type        = string
  default     = ""
}

variable "application_name" {
  description = "The name of your application"
  type        = string
}

variable "subsystem_name" {
  description = "The subsystem name of your application"
  type        = string
}

variable "package_name" {
  description = "The name of the package to use for the function"
  type        = string
  default     = "s3"
}

variable "newline_pattern" {
  description = "The pattern for lines splitting"
  type        = string
  default     = "(?:\\r\\n|\\r|\\n)"
}

variable "blocking_pattern" {
  description = "The pattern for lines blocking"
  type        = string
  default     = ""
}

variable "buffer_size" {
  description = "Coralogix logger buffer size"
  type        = number
  default     = 134217728
}

variable "sampling_rate" {
  description = "Send messages with specific rate"
  type        = number
  default     = 1
}

variable "debug" {
  description = "Coralogix logger debug mode"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to watch"
  type        = string
}

variable "s3_key_prefix" {
  description = "The S3 path prefix to watch"
  type        = string
  default     = null
}

variable "s3_key_suffix" {
  description = "The S3 path suffix to watch"
  type        = string
  default     = null
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

variable "integration_type" {
  description = "the aws service that send the data to the s3"
  type        = string
  validation {
    condition     = contains(["cloudtrail", "vpc-flow-logs", "s3", "s3-sns", "cloudtrail-sns"], var.integration_type)
    error_message = "The integration type must be: [cloudtrail, vpc-flow-logs, s3, s3-sns, cloudtrail-sns]."
  }
}

variable "sns_topic_name" {
  description = "The name of your SNS topic"
  type        = string
  default     = ""
}

variable "custom_s3_bucket" {
  description = "The name of the s3 bucket to save the lambda zip code in"
  type        = string
  default     = ""
}

variable "create_secret" {
  description = "Set to False In case you want to use secrets manager with a predefine secret that was already created and contains Coralogix Send Your Data API key"
  type        = string
  default     = "True"
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Retention time of the Cloudwatch log group in which the logs of the lambda function are written to"
  type        = number
  default     = null
}

