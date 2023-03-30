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

variable "include_all_namespaces" {
  type        = bool
  description = "If set to true, the CloudWatch metric stream will include all available namespaces"
  default     = false
}

variable "include_metric_stream_namespaces" {
  description = "List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html"
  type        = list(string)
  default     = ["EC2", "DynamoDB"]
}

variable "user_supplied_tags" {
  description = "Tags supplied by the user to populate to all generated resources"
  type        = map(string)
  default     = { custom-tag-sample="value1" }
}

variable "cloudwatch_retention_days" {
  description = "Days of retention in Cloudwatch retention days"
  type        = number
  default     = 1
}
