variable "coralogix_firehose_stream_name" {
  description = "Coralogix firehose delivery stream name"
  type        = string
  default     = "coralogix-firehose"
}

variable "coralogix_region" {
  type        = string
  description = "The region of the Coralogix account"
}

variable "coralogix_privatekey" {
  type        = string
  description = "Coralogix account logs private key"
  sensitive   = true
}

variable "logs_enable" {
  description = "Enble sending logs to Coralogix"
  type        = bool
  default     = false
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

variable "dynamic_metadata_logs" {
  description = "Dynamic values search for specific fields in the logs to populate the fields"
  type        = bool
  default     = false
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
