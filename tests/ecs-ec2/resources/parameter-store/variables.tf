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