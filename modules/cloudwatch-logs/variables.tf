variable "coralogix_region" {
  description = "The Coralogix location region, possible options are [Europe, Europe2, India, Singapore, US]"
  type        = string
  default     = "Europe"
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

variable "newline_pattern" {
  description = "The pattern for lines splitting"
  type        = string
  default     = "(?:\r\n|\r|\n)"
}

variable "buffer_charset" {
  description = "The charset to use for buffer decoding, possible options are [utf8, ascii]"
  type        = string
  default     = "utf8"
}

variable "sampling_rate" {
  description = "Send messages with specific rate"
  type        = string
  default     = "1"
}

variable "log_group" {
  description = "The name of the CloudWatch log group to watch"
  type        = string
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
