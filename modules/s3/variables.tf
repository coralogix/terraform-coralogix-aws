variable "coralogix_region" {
  description = "The Coralogix location region, possible options are [Europe, Europe2, India, Singapore, US]"
  type        = string
  validation {
    condition = contains([
      "Europe", "Europe2", "India", "Singapore", "US", "US2", "Custom"
    ], var.coralogix_region)
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

variable "layer_arn" {
  description = " In case you are using SSM This is the ARN of the Coralogix Security Layer."
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

variable "sns_topic_name" {
  description = "The name of your SNS topic"
  type        = string
  default     = null
}

variable "custom_s3_bucket" {
  description = "The name of the s3 bucket to save the lambda zip code in"
  type        = string
  default     = ""
}

variable "create_secret" {
  description = "Set to False In case you want to use SSM with your secret that contains coralogix private key"
  type        = string
  default     = "True"
}

variable "s3_bucket_name" {
  type = string
}

variable "log_info" {
  type = map(object({
    s3_key_prefix    = optional(string)
    s3_key_suffix    = optional(string)
    application_name = string
    subsystem_name   = string
    integration_type = string
    newline_pattern  = optional(string)
    blocking_pattern = optional(string)
  }))
  validation {
    condition = alltrue([
      for bucket_info in var.log_info :contains([
        "cloudtrail", "vpc-flow-logs", "s3", "s3-sns", "cloudtrail-sns"
      ], bucket_info.integration_type)
    ] )
    error_message = "All integration types must be: [cloudtrail, vpc-flow-logs, s3, s3-sns, cloudtrail-sns]."
  }

}
