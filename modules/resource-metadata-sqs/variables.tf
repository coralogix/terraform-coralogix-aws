### Coralogix Configuration

variable "coralogix_region" {
  description = "The Coralogix location region [EU1, EU2, AP1, AP2, US1, US2, Custom]"
  type        = string
  validation {
    condition     = contains(["EU1", "EU2", "AP1", "AP2", "AP3", "US1", "US2", "Custom"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [EU1, EU2, AP1, AP2, AP3, US1, US2, Custom]."
  }
  default = "Custom"
}

variable "api_key" {
  description = "Your Coralogix Send Your Data - API Key or incase you use pre created secret (created in AWS secret manager) put here the name of the secret that contains the Coralogix send your data key"
  type        = string
  sensitive   = true
}

variable "custom_url" {
  description = "The Coralogix custom domain"
  type        = string
  default     = ""
}

### Event Mode Configuration

variable "event_mode" {
  description = "Enable real-time processing of CloudTrail events via EventBridge [Disabled, EnabledWithExistingTrail, EnabledCreateTrail]"
  type        = string
  validation {
    condition     = contains(["Disabled", "EnabledWithExistingTrail", "EnabledCreateTrail"], var.event_mode)
    error_message = "The event mode must be one of these values: [Disabled, EnabledWithExistingTrail, EnabledCreateTrail]."
  }
  default = "Disabled"
}

variable "organization_id" {
  description = "AWS Organization ID (starts with 'o-'). Leave empty to disable cross-account access."
  type        = string
  default     = ""
  validation {
    condition     = var.organization_id == "" || substr(var.organization_id, 0, 2) == "o-"
    error_message = "The organization ID must start with 'o-'."
  }
}

### Cross-Account and Cross-Region Configuration

variable "source_regions" {
  description = "The regions to collect metadata from, separated by commas (e.g. eu-north-1,eu-west-1,us-east-1). Leave empty if you want to collect metadata from the current region only."
  type        = list(string)
  default     = []
}

variable "crossaccount_mode" {
  description = "Enable cross-account access mode [Disabled, StaticIAM, Config]"
  type        = string
  validation {
    condition     = contains(["Disabled", "StaticIAM", "Config"], var.crossaccount_mode)
    error_message = "The cross-account mode must be one of these values: [Disabled, StaticIAM, Config]."
  }
  default = "Disabled"
}

variable "crossaccount_config_aggregator" {
  description = "The name of the AWS Config aggregator to collect metadata from. Used only when crossaccount_mode is Config."
  type        = string
  default     = ""
}

variable "crossaccount_account_ids" {
  description = "The account IDs to collect metadata from, separated by commas (e.g. 123456789012,123456789013). Used only when crossaccount_mode is StaticIAM."
  type        = list(string)
  default     = []
}

variable "crossaccount_iam_role_name" {
  description = "The name of the IAM role to collect metadata from. Used when crossaccount_mode is not Disabled."
  type        = string
  default     = ""
}

### Integration Configuration

variable "schedule" {
  description = "Collect metadata on a specific schedule"
  type        = string
  default     = "rate(30 minutes)"
}

variable "latest_versions_per_function" {
  description = "How many latest published versions of each Lambda function should be collected"
  type        = number
  default     = 0
  validation {
    condition     = var.latest_versions_per_function >= 0
    error_message = "Latest versions per function must be greater than or equal to 0."
  }
}

variable "collect_aliases" {
  description = "Collect Aliases [True/False]"
  type        = bool
  default     = false
}

variable "lambda_function_include_regex_filter" {
  description = "If specified, only lambda functions with ARNs matching the regex will be included in the collected metadata"
  type        = string
  default     = ""
}

variable "lambda_function_exclude_regex_filter" {
  description = "If specified, only lambda functions with ARNs NOT matching the regex will be included in the collected metadata"
  type        = string
  default     = ""
}

variable "lambda_telemetry_exporter_filter" {
  description = "If set to true, only lambda functions with coralogix-telemetry-exporter layer will be included in the collected metadata"
  type        = bool
  default     = false
}

variable "lambda_function_tag_filters" {
  description = "If specified, only lambda functions with tags matching the filters will be included in the collected metadata. Values should follow the JSON syntax for --tag-filters as documented here: https://docs.aws.amazon.com/cli/latest/reference/resourcegroupstaggingapi/get-resources.html#options"
  type        = string
  default     = ""
}

variable "resource_ttl_minutes" {
  description = "Once a resource is collected, how long should it remain valid?"
  type        = number
  default     = 60
}

variable "notification_email" {
  description = "Failure notification email address"
  type        = string
  default     = ""
}

variable "package_name" {
  description = "Package name for the Lambda function"
  type        = string
  default     = "resource-metadata-sqs"
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

variable "excluded_ec2_resource_type" {
  description = "Is EC2 Resource Type Excluded?"
  type        = bool
  default     = false
}

variable "excluded_lambda_resource_type" {
  description = "Is Lambda Resource Type Excluded?"
  type        = bool
  default     = false
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Retention time of the Cloudwatch log group in which the logs of the lambda function are written to"
  type        = number
  default     = null
}

### Lambda Configuration

variable "architecture" {
  description = "Lambda function architecture [x86_64, arm64]"
  type        = string
  validation {
    condition     = contains(["x86_64", "arm64"], var.architecture)
    error_message = "Architecture must be either x86_64 or arm64."
  }
  default = "x86_64"
}

variable "memory_size" {
  description = "Lambda function memory limit"
  type        = number
  default     = 256
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 and 10240."
  }
}

variable "timeout" {
  description = "Lambda function timeout limit"
  type        = number
  default     = 300
  validation {
    condition     = var.timeout >= 30 && var.timeout <= 900
    error_message = "Timeout must be between 30 and 900 seconds."
  }
}

variable "maximum_concurrency" {
  description = "Maximum number of concurrent SQS messages to process"
  type        = number
  default     = 5
  validation {
    condition     = var.maximum_concurrency >= 1 && var.maximum_concurrency <= 1000
    error_message = "Maximum concurrency must be between 1 and 1000."
  }
}

### Security Configuration

variable "layer_arn" {
  description = "In case you are using Secret Manager This is the ARN of the Coralogix Security lambda Layer."
  type        = string
  default     = ""
}

variable "secret_manager_enabled" {
  description = "Set to true in case that you want to keep your Coralogix Send Your Data API Key as a secret in aws Secret Manager"
  type        = bool
  default     = false
}
