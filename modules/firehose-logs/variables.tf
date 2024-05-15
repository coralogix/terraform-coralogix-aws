variable "coralogix_region" {
  description = "Coralogix account region: Europe, Europe2, India, Singapore, US, US2"
  type        = string
  validation {
    condition     = contains(["Europe", "Europe2", "India", "Singapore", "US", "US2"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [Europe, Europe2, India, Singapore, US, US2]."
  }
}

variable "private_key" {
  description = "Coralogix account private key"
  type        = string
  sensitive   = true
}

variable "firehose_stream" {
  description = "AWS Kinesis firehose delivery stream name"
  type        = string
}

variable "application_name" {
  description = "The name of your application in Coralogix"
  type        = string
  default     = null
}

variable "subsystem_name" {
  description = "The subsystem name of your application in Coralogix"
  type        = string
  default     = null
}

variable "cloudwatch_retention_days" {
  description = "Days of retention in Cloudwatch retention days"
  type        = number
  default     = 1
}

variable "custom_domain" {
  description = "Custom domain for Coralogix firehose integration endpoint (e.g. private.coralogix.net:8443 for https://firehose-ingress.private.coralogix.net:8443/firehose)"
  type        = string
  default     = null
}

variable "source_type_logs" {
  description = "The source_type of kinesis firehose: KinesisStreamAsSource or DirectPut"
  type        = string
  default     = "DirectPut"
}

variable "kinesis_stream_arn" {
  description = "If 'KinesisStreamAsSource' set as source_type_logs. Set the kinesis stream's ARN as the source of the firehose log stream"
  type        = string
  default     = null
}

variable "integration_type_logs" {
  description = "The integration type of the firehose delivery stream: 'CloudWatch_JSON', 'WAF', 'CloudWatch_CloudTrail', 'EksFargate', 'Default', 'RawText'"
  type        = string
  default     = null
}

variable "user_supplied_tags" {
  description = "Tags supplied by the user to populate to all generated resources"
  type        = map(string)
  default     = {}
}

variable "override_default_tags" {
  description = "Override and remove the default tags by setting to true"
  type        = bool
  default     = false
}

variable "s3_backup_custom_name" {
  description = "Set the name of the S3 backup bucket, otherwise variable '{firehose_stream}-backup-logs' will be used"
  type        = string
  default     = null
}
