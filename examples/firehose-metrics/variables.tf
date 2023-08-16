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

variable "metric_enable" {
  description = "Enable sending of metrics to Coralogix"
  type        = bool
  default     = true
}

variable "integration_type_metrics" {
  description = "The integration type of the firehose delivery stream: 'CloudWatch_Metrics_JSON' or 'CloudWatch_Metrics_OpenTelemetry070'"
  type        = string
  default     = "CloudWatch_Metrics_OpenTelemetry070"
}

variable "enable_cloudwatch_metricstream" {
  description = "Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose"
  type        = bool
  default     = true
}

variable "include_metric_stream_namespaces" {
  description = "List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html"
  type        = list(string)
  default     = ["AWS/EC2", "AWS/DynamoDB"]
}

variable "include_metric_stream_filter" {
  description = "List of inclusive metric filters for namespace and metric_names. Specify this parameter, the stream sends only the conditional metric names from the metric namespaces that you specify here. If metric names is empty or not specified, the whole metric namespace is included"
  type = list(object({
    namespace    = string
    metric_names = list(string)
    })
  )
  default = [
    {
      namespace    = "AWS/EC2"
      metric_names = ["CPUUtilization", "NetworkOut"]
    },
    {
      namespace    = "AWS/S3"
      metric_names = ["BucketSizeBytes"]
    },
  ]
}

variable "additional_metric_statistics_enable" {
  description = "To enable the inclusion of additional statistics to the streaming metrics"
  type        = bool
  default     = true
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

variable "output_format" {
  description = "The output format of the cloudwatch metric stream: 'json' or 'opentelemetry0.7'"
  type        = string
  default     = "opentelemetry0.7"
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
