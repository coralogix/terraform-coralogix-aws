variable "log_group_permissions_prefix" {
  description = "A list of strings of log group prefixes. The code will use these prefixes to create permissions for the Lambda instead of creating for each log group permission it will use the prefix with a wild card to give the Lambda access for all of the log groups that start with these prefix. This parameter doesn't replace the regex_pattern parameter."
  type        = list(string)
  default     = []
}

variable "disable_add_permission" {
  description = "Disable the add permission to the destination loggroup"
  type        = bool
  default     = false
}

variable "regex_pattern" {
  description = "Regex that matches the log group names to subscribe to the destination"
  type        = string

  validation {
    condition     = trimspace(var.regex_pattern) != ""
    error_message = "regex_pattern must not be empty."
  }
}

variable "destination_role" {
  description = "Arn for the role to allow destination subscription to be pushed (In case you use Firehose)"
  type        = string
  default     = null
}

variable "logs_filter" {
  description = "Subscription filter to select which logs needs to be sent to Coralogix. For Example for Lambda Errors that are not sendable by Coralogix Lambda Layer '?REPORT ?\"Task timed out\" ?\"Process exited before completing\" ?errorMessage ?\"module initialization error:\" ?\"Unable to import module\" ?\"ERROR Invoke Error\" ?\"EPSAGON_TRACE:\"'."
  type        = string
  default     = ""
}

variable "destination_arn" {
  description = "Arn for the firehose to subscribe the log groups (By default is the firehose created by Serverless Template)"
  type        = string
}

variable "destination_type" {
  description = "Destination type: lambda or firehose. Must match the service in destination_arn."
  type        = string

  validation {
    condition     = contains(["lambda", "firehose"], lower(var.destination_type))
    error_message = "destination_type must be lambda or firehose."
  }
}

variable "scan_old_loggroups" {
  description = "Deprecated and ignored. Lambda Manager 3.0.0 always scans existing log groups. This variable will be removed in the next major release."
  type        = string
  default     = "false"
}

variable "add_permissions_to_all_log_groups" {
  description = "Add one wildcard permission for all log groups in this account and region instead of one per log group. Lambda destinations only."
  type        = bool
  default     = false
}

variable "memory_size" {
  description = "The maximum allocated memory this lambda may consume. Default value is the minimum recommended setting please consult coralogix support before changing."
  type        = number
  default     = 1024
}

variable "timeout" {
  description = "The maximum time in seconds the function may be allowed to run. Default value is the minimum recommended setting please consult coralogix support before changing."
  type        = number
  default     = 900
}

variable "architecture" {
  description = "Lambda function architecture, possible options are [x86_64, arm64]"
  type        = string
  default     = "arm64"
}

variable "notification_email" {
  description = "Failure notification email address"
  type        = string
  default     = null
}

variable "sns_kms_key_arn" {
  description = "Optional KMS key ARN (not an alias) to encrypt the Lambda failure-notification SNS topic. Leave null for no encryption. The key policy must allow sns.amazonaws.com and the Lambda execution role to use kms:Decrypt and kms:GenerateDataKey*."
  type        = string
  default     = null

  validation {
    condition     = var.sns_kms_key_arn == null || can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:key/", var.sns_kms_key_arn))
    error_message = "sns_kms_key_arn must be a KMS key ARN (arn:...:kms:...:key/...), not an alias."
  }
}

variable "lambda_manager_version" {
  description = "Lambda Manager package version to deploy from the Coralogix S3 bucket"
  type        = string
  default     = "3.0.0"
}

variable "adopt_legacy_filters" {
  description = "Take over old Coralogix UUID subscription filters. Keep false unless you are migrating."
  type        = bool
  default     = false
}

variable "aws_api_requests_limit" {
  description = "Max AWS API requests the function may send. Raise it if you see ThrottlingException."
  type        = number
  default     = 10
}

variable "enable_reconcile" {
  description = "Invoke the function after apply to subscribe existing log groups, and clean up on destroy. Set false to run it yourself."
  type        = bool
  default     = true
}
