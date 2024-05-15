variable "coralogix_region" {
  description = "Coralogix account region: Europe, Europe2, India, Singapore, US, US2"
  type        = string
  validation {
    condition     = contains(["Europe", "Europe2", "India", "Singapore", "US", "US2"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [Europe, Europe2, India, Singapore, US, US2]."
  }
}

variable "private_key" {
  description = "Coralogix account private key"
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
  description = "Custom domain for Coralogix firehose integration endpoint (e.g. private.coralogix.net:8443 for https://firehose-ingress.private.coralogix.net:8443/firehose)"
  type        = string
  default     = null
}

variable "integration_type_metrics" {
  description = "The integration type of the firehose delivery stream: 'CloudWatch_Metrics_OpenTelemetry070' or 'CloudWatch_Metrics_OpenTelemetry070_WithAggregations'"
  type        = string
  default     = "CloudWatch_Metrics_OpenTelemetry070_WithAggregations"
}

variable "output_format" {
  description = "The output format of the cloudwatch metric stream: 'json' or 'opentelemetry0.7'"
  type        = string
  default     = "opentelemetry0.7"
}

variable "enable_cloudwatch_metricstream" {
  description = "Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose"
  type        = bool
  default     = true
}

variable "cloudwatch_metric_stream_custom_name" {
  description = "Set the name of the CloudWatch metric stream, otherwise variable 'firehose_stream' will be used"
  type        = string
  default     = null
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

variable "additional_metric_statistics_enable" {
  description = "To enable the inclusion of additional statistics to the streaming metrics"
  type        = bool
  default     = false
}

variable "additional_metric_statistics" {
  description = "For each entry, specify one or more metrics (metric_name and namespace) and the list of additional statistics to stream for those metrics. Each configuration of metric name and namespace can have a list of additional_statistics included into the AWS CloudWatch Metric Stream"
  type = list(object({
    additional_statistics = list(string)
    metric_name           = string
    namespace             = string
  }))
  default = [
    {
      additional_statistics = ["p50", "p75", "p95", "p99"],
      metric_name           = "VolumeTotalReadTime",
      namespace             = "AWS/EBS"
    },
    {
      additional_statistics = ["p50", "p75", "p95", "p99"],
      metric_name           = "VolumeTotalWriteTime",
      namespace             = "AWS/EBS"
    },
    {
      additional_statistics = ["p50", "p75", "p95", "p99"],
      metric_name           = "Latency",
      namespace             = "AWS/ELB"
    },
    {
      additional_statistics = ["p50", "p75", "p95", "p99"],
      metric_name           = "Duration",
      namespace             = "AWS/ELB"
    },
    {
      additional_statistics = ["p50", "p75", "p95", "p99"],
      metric_name           = "PostRuntimeExtensionsDuration",
      namespace             = "AWS/Lambda"
    },
    {
      additional_statistics = ["p50", "p75", "p95", "p99"],
      metric_name           = "FirstByteLatency",
      namespace             = "AWS/S3"
    },
    {
      additional_statistics = ["p50", "p75", "p95", "p99"],
      metric_name           = "TotalRequestLatency",
      namespace             = "AWS/S3"
    }
  ]
}

variable "lambda_processor_enable" {
  description = "Enable lambda processor function, defaults to true"
  type        = bool
  default     = true
}

variable "lambda_processor_custom_name" {
  description = "Set the name of the lambda processor function, otherwise variable '{firehose_stream}-metrics-tags-processor' will be used"
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

variable "s3_backup_custom_name" {
  description = "Set the name of the S3 backup bucket, otherwise variable '{firehose_stream}-backup' will be used"
  type        = string
  default     = null
}