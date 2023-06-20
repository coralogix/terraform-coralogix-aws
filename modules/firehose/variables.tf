variable "firehose_stream" {
  description = "AWS Kinesis firehose delivery stream name"
  type        = string
}

variable "privatekey" {
  description = "Coralogix account private key"
  sensitive   = true
}

variable "coralogix_region" {
  description = "Coralogix account region: us, singapore, ireland, india, stockholm [in lower-case letters]"
}

variable "include_metric_stream_namespaces" {
  description = "List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html"
  type        = list(string)
  default     = []
}

variable "include_metric_stream_filter" {
  description = "List of inclusive metric filters for namespace and metric_names. Specify this parameter, the stream sends only the conditional metric names from the metric namespaces that you specify here. If metric names is empty or not specified, the whole metric namespace is included"
  type = list(object({
    namespace    = string
    metric_names = list(string)
    })
  )
  default = []
}

variable "enable_cloudwatch_metricstream" {
  description = "Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose"
  type        = bool
  default     = true
}

variable "output_format" {
  description = "The output format of the cloudwatch metric stream: 'json' or 'opentelemetry0.7'"
  type        = string
  default     = "opentelemetry0.7"
}

variable "integration_type" {
  description = "The integration type of the firehose delivery stream: 'CloudWatch_Metrics_JSON' or 'CloudWatch_Metrics_OpenTelemetry070'"
  type        = string
  default     = "CloudWatch_Metrics_OpenTelemetry070"
}

variable "application_name" {
  description = "The application name of the metrics"
  type        = string
  default     = null
}

variable "user_supplied_tags" {
  description = "Tags supplied by the user to populate to all generated resources"
  type        = map(string)
  default     = {}
}

variable "cloudwatch_retention_days" {
  description = "Days of retention in Cloudwatch retention days"
  type        = number
  default     = 1
}

variable "coralogix_firehose_custom_endpoint" {
  description = "Custom endpoint for Coralogix firehose integration endpoint (https://firehose-ingress.private.coralogix.net:8443/firehose)"
  type        = string
  default     = null
}
