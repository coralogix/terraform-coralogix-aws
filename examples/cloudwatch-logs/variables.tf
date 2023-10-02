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
  description = "Your Coralogix Send Your Data - API Key or incase you use pre created secret (created in AWS secret manager) put here the name of the secret that contains the Coralogix send your data key"
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

variable "newline_pattern" {
  description = "The pattern for lines splitting"
  type        = string
  default     = "(?:\\r\\n|\\r|\\n)"
}

variable "buffer_charset" {
  description = "The charset to use for buffer decoding, possible options are [utf8, ascii]"
  type        = string
  default     = "utf8"
}

variable "sampling_rate" {
  description = "Send messages with specific rate"
  type        = number
  default     = 1
}

variable "log_groups" {
  description = "The names of the CloudWatch log groups to watch"
  type        = list(string)
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

variable "layer_arn" {
  description = "In case you are using Secret Manager This is the ARN of the Coralogix Security lambda Layer."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "The subnet id with the private link"
  type        = list(string)
  default     = [""]
}

variable "security_group_ids" {
  description = "The security group id for assigned to the subnet_ids"
  type        = list(string)
  default     = [""]
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