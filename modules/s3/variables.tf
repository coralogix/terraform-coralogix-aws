variable "coralogix_region" {
  description = "The Coralogix location region, possible options are [Europe, Europe2, India, Singapore, US]"
  type        = string
  validation {
    condition     = contains(["Europe", "Europe2", "India", "Singapore", "US", "US2", "Custom"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [Europe, Europe2, India, Singapore, US, US2, Custom]."
  }
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

# variable "ssm_enable" {
#   description = "Use SSM for the private key True/False"
#   type        = string
#   default     = "False"
# }

variable "layer_arn" {
  description = " In case you are using SSM This is the ARN of the Coralogix Security Layer."
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

variable "create_secret" {
  description = "Set to false In case you want to use SSM with your secret that contains coralogix private key"
  type        = string
  default     = "True"
}
