variable "coralogix_region" {
  description = "Coralogix account region: EU1, EU2, AP1, AP2, AP3, US1, US2"
  type        = string
  validation {
    condition     = contains(["EU1", "EU2", "AP1", "AP2", "AP3", "US1", "US2"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [EU1, EU2, AP1, AP2, AP3, US1, US2]."
  }
}

variable "api_key" {
  description = "Coralogix account api key"
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
  description = "Custom domain for Coralogix firehose integration endpoints, does not work for privatelink (e.g. cust.coralogix-123.net:8443 for https://ingress.cust.coralogix-123.net:8443/aws/firehose)"
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

variable "s3_backup_custom_name" {
  description = "Set the name of the S3 backup bucket, otherwise variable '{firehose_stream}-backup-logs' will be used"
  type        = string
  default     = null
}

variable "existing_s3_backup" {
  description = "Use an existing S3 bucket to use as a backup bucket"
  type        = string
  default     = null
}

variable "govcloud_deployment" {
  description = "Enable if you deploy the integration in govcloud"
  type        = bool
  default     = false
}

variable "firehose_iam_custom_name" {
  description = "Set the name of the firehose IAM role & policy, otherwise variable '{firehose_stream}-firehose-logs-iam' will be used"
  type        = string
  default     = null
}

variable "existing_firehose_iam" {
  description = "Use an existing IAM role to use as a firehose role"
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
