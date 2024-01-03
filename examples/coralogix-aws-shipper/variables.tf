variable "coralogix_region" {
  description = "The Coralogix location region, possible options are [EU1, EU2, AP1, AP2, US1, US2]"
  type        = string
  validation {
    condition     = contains(["EU1", "EU2", "AP1", "AP2", "US1", "US2", "Custom"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [EU1, EU2, AP1, AP2, US1, US2, Custom]."
  }
}

variable "custom_domain" {
  description = "Your Custom domain for the Coralogix account."
  type        = string
  default     = ""
}

variable "api_key" {
  description = "Your Coralogix Send Your Data - API Key which is used to validate your authenticity, This value can be a Coralogix API Key or an AWS Secret Manager ARN that holds the API Key"
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
  description = "The AWS S3 path prefix to watch. This value is ignored when the SNSTopicArn parameter is provided."
  type        = string
  default     = null
}

variable "s3_key_suffix" {
  description = "The AWS S3 path suffix to watch. This value is ignored when the SNSTopicArn parameter is provided."
  type        = string
  default     = null
}

variable "log_groups" {
  description = "The names of the CloudWatch log groups to watch"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "ID of Subnet into which to deploy the integration"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "ID of the SecurityGroup into which to deploy the integration"
  type        = list(string)
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
    condition     = contains(["CloudWatch", "CloudTrail", "VpcFlow", "S3", "S3Csv", "Sns"], var.integration_type)
    error_message = "The integration type must be: [CloudWatch, CloudTrail, VpcFlow, S3, S3Csv, Sns]."
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

variable "log_level" {
  type        = string
  description = "Log level for the Lambda function. Can be one of: INFO, WARN, ERROR, DEBUG"
  default     = "WARN"
  validation {
    condition     = contains(["INFO", "ERROR", "WARN", "DEBUG"], var.log_level)
    error_message = "The log leavel must be one of these values: [DEBUG, WARN, ERROR, INFO]."
  }
}

variable "lambda_log_retention" {
  description = "CloudWatch log retention days for logs generated by the Lambda function"
  type        = number
  default     = 5
}

variable "store_api_key_in_secrets_manager" {
  description = "Store the API key in AWS Secrets Manager. ApiKeys are stored in secret manager \nby default. If this option is set to false, the ApiKey will appear in plain text as an \n environment variable in the lambda function console."
  type        = bool
  default     = true
}

variable "cs_delimiter" {
  type = string
  description = "The delimiter used in the CSV file to process This value is applied when the S3Csv integration type is selected"
  default = ","
}

variable "lambda_name" {
  type = string
  description = "The name of the lambda function"
  default = null
}
