variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "api_key" {
  description = "Coralogix API key for data ingestion"
  type        = string
  sensitive   = true
  default     = "cxtp_CoralogixSendYourDataKey"
}

variable "s3_config_bucket_arn" {
  description = "ARN of the S3 bucket containing OTEL config (for execution role S3 access)"
  type        = string
  default     = null
} 