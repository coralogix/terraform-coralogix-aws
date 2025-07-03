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

variable "memory_size" {
  description = "Lambda function memory limit"
  type        = number
  default     = 256
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

variable "schedule" {
  description = ""
  type        = string
  default     = "rate(10 minutes)"
}

variable "latest_versions_per_function" {
  description = "How many latest published versions of each Lambda function should be collected"
  type        = number
  default     = 5
}

variable "resource_ttl_minutes" {
  type        = number
  description = "Once a resource is collected, how long should it remain valid"
  default     = 60
}

variable "notification_email" {
  description = "Failure notification email address"
  type        = string
  default     = null
}

variable "package_name" {
  description = "Failure notification email address"
  type        = string
  default     = "resource-metadata"
}

variable "collect_aliases" {
  description = "Collect Aliases"
  type        = bool
  default     = false
}

variable "lambda_function_include_regex_filter" {
  description = "If specified, only lambda functions with ARNs matching the regex will be included in the collected metadata"
  type        = string
  default     = null
}

variable "lambda_function_exclude_regex_filter" {
  description = "If specified, only lambda functions with ARNs NOT matching the regex will be included in the collected metadata"
  type        = string
  default     = null
}

variable "lambda_function_tag_filters" {
  description = "If specified, only lambda functions with tags matching the filters will be included in the collected metadata. Values should follow the JSON syntax for --tag-filters as documented here: https://docs.aws.amazon.com/cli/latest/reference/resourcegroupstaggingapi/get-resources.html#options"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "custom_s3_bucket" {
  description = "The name of the s3 bucket to save the lambda zip code in"
  type        = string
  default     = ""
}

variable "create_secret" {
  description = "Set to False In case you want to use secrets manager with a predefine secret that was already created and contains Coralogix Send Your Data API key"
  type        = bool
  default     = true
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Retention time of the Cloudwatch log group in which the logs of the lambda function are written to"
  type        = number
  default     = null
}