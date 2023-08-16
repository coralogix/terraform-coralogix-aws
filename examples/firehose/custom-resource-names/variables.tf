variable "firehose_stream" {
  description = "Coralogix firehose delivery stream name"
  type        = string
  default     = "coralogix-firehose"
}

variable "coralogix_region" {
  type        = string
  description = "The region of the Coralogix account"
}

variable "private_key" {
  type        = string
  description = "Coralogix account logs private key"
  sensitive   = true
}

variable "cloudwatch_metric_stream_custom_name" {
  description = "Set the name of the CloudWatch metric stream, otherwise variable 'firehose_stream' will be used"
  type        = string
  default     = "test_cloudwatch_metric_stream_for_example"
}

variable "s3_backup_custom_name" {
  description = "Set the name of the S3 backup bucket, otherwise variable '{firehose_stream}-backup' will be used"
  type        = string
  default     = "test_s3_backup_custom_name_for_example"
}

variable "lambda_processor_custom_name" {
  description = "Set the name of the lambda processor function, otherwise variable '{firehose_stream}-metrics-tags-processor' will be used"
  type        = string
  default     = "test_lambda_processor_custom_name_for_example"
}
