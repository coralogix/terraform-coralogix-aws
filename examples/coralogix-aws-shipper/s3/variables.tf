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

variable "api_key" {
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
}

variable "newline_pattern" {
  description = "The pattern for lines splitting"
  type        = string
  default     = ""
}

variable "blocking_pattern" {
  description = "The pattern for lines blocking"
  type        = string
  default     = ""
}

variable "sampling_rate" {
  description = "Send messages with specific rate"
  type        = number
  default     = 1
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to watch"
  type        = string
  default     = null
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

variable "log_groups" {
  description = "The names of the CloudWatch log groups to watch"
  type        = list(string)
  default     = []
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
    condition     = contains(["cloudwatch", "cloudtrail", "vpcflow", "s3", "s3-sns", "cloudtrail-sns","s3_csv"], var.integration_type)
    error_message = "The integration type must be: [cloudwatch, cloudtrail, vpcflow, s3, s3-sns, cloudtrail-sns,s3_csv]."
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

variable "rust_log" {
  type        = string
  description = "RUST log leavel"
  default     = "INFO"
  validation {
    condition     = contains(["INFO", "ERROR", "WARNING", "DEBUG"], var.rust_log)
    error_message = "The log leavel must be one of these values: [DEBUG, WARNING, ERROR, INFO]."
  }
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Retention time of the Cloudwatch log group in which the logs of the lambda function are written to"
  type        = number
  default     = null
}

variable "store_api_key_in_secrets_manager" {
  description = "Store the API key in AWS Secrets Manager. ApiKeys are stored in secret manager \nby default. If this option is set to false, the ApiKey will apeear in plain text as an \n environment variable in the lambda function console."
  type        = bool
  default     = false
}