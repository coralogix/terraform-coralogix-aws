variable "coralogix_firehose_stream_name" {
  description = "Coralogix firehose delivery stream name"
  type        = string
  default = "coralogix-firehose"
}

variable "coralogix_endpoint_url" {
  type        = string
  description = "Coralogix endpoint url"
}

variable "coralogix_privatekey" {
  type        = string
  description = "Coralogix account logs private key"
  sensitive = true
}

variable "include_all_namespaces" {
  type = bool
  description = "If set to true, the CloudWatch metric stream will include all available namespaces"
  default = false
}

variable "include_metric_stream_namespaces" {
  description = "List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html"
  type        = list(string)
  default     = ["EC2", "DynamoDB"]
}