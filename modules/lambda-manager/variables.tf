variable "regex_pattern" {
  description = "Set up this regex to match the Log Groups names that you want to automatically subscribe to the destination"
  type        = string
}

variable "destination_role" {
  description = "Arn for the role to allow destination subscription to be pushed (In case you use Firehose)"
  type        = string
  default     = null
}

variable "logs_filter" {
  description = "Subscription filter to select which logs needs to be sent to Coralogix. For Example for Lambda Errors that are not sendable by Coralogix Lambda Layer '?REPORT ?\"Task timed out\" ?\"Process exited before completing\" ?errorMessage ?\"module initialization error:\" ?\"Unable to import module\" ?\"ERROR Invoke Error\" ?\"EPSAGON_TRACE:\"'."
  type        = string
}

variable "destination_arn" {
  description = "Arn for the firehose to subscribe the log groups (By default is the firehose created by Serverless Template)"
  type        = string
}

variable "destination_type" {
  description = "Type of destination (Lambda or Firehose)"
  type        = string
}

variable "scan_old_loggroups" {
  description = "This will scan all LogGroups in the account and apply the subscription configured, will only run Once and set to false. Default is false"
  type        = string
  default     = "false"
}

variable "memory_size" {
  description = "The maximum allocated memory this lambda may consume. Default value is the minimum recommended setting please consult coralogix support before changing."
  type        = number
  default     = 1024
}

variable "timeout" {
  description = "The maximum time in seconds the function may be allowed to run. Default value is the minimum recommended setting please consult coralogix support before changing."
  type        = number
  default     = 300
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
