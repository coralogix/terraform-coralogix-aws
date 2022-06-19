variable "firehose_stream" {
  description = "AWS Kinesis firehose delivery stream name"
  type        = string
}

variable "privatekey" {
  description = "Coralogix account logs private key"
  sensitive   = true

}

variable "endpoint_url" {
  description = "Firehose endpoint, see https://github.com/coralogix/terraform-coralogix-aws/blob/master/modules/firehose/README.md#Coralogix"
  type        = string
}

variable "include_all_namespaces" {
  description = "If set to true, the CloudWatch metric stream will include all available namespaces"
  type        = bool
  default     = true
}

variable "include_metric_stream_namespaces" {
  description = "List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html"
  type        = list(string)
  default     = []
}

variable "enable_cloudwatch_metricstream" {
  description = "Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose"
  type        = bool
  default     = true
}

