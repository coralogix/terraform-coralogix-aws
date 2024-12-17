variable "firehose_stream" {
  description = "Coralogix firehose delivery stream name"
  type        = string
  default     = "coralogix-firehose"
}

variable "coralogix_region" {
  type        = string
  description = "The region of the Coralogix account"
}

variable "api_key" {
  type        = string
  description = "Coralogix account api key"
  sensitive   = true
}

variable "source_type_logs" {
  description = "The source_type of kinesis firehose: KinesisStreamAsSource or DirectPut"
  type        = string
  default     = "DirectPut"
}

variable "kinesis_stream_arn" {
  description = "The kinesis stream name for the logs - used in kinesis stream as a source"
  type        = string
  default     = ""
}

variable "integration_type_logs" {
  description = "The integration type of the firehose delivery stream: 'CloudWatch_JSON', 'WAF', 'CloudWatch_CloudTrail', 'EksFargate', 'Default', 'RawText'"
  type        = string
  default     = "Default"
}

variable "application_name" {
  description = "The name of your application in Coralogix"
  type        = string
  default     = null
}

variable "subsystem_name" {
  description = "The subsystem name of your application in Coralogix"
  type        = string
  default     = ""
}

variable "user_supplied_tags" {
  description = "Tags supplied by the user to populate to all generated resources"
  type        = map(string)
  default     = { custom-tag-sample = "value1" }
}

variable "cloudwatch_retention_days" {
  description = "Days of retention in Cloudwatch retention days"
  type        = number
  default     = 1
}

variable "govcloud_deployment" {
  description = "Enable if you deploy the integration in govcloud"
  type        = bool
  default     = false
}
