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
      additional_statistics = ["p75", "p99"],
      metric_name           = "VolumeTotalReadTime",
      namespace             = "AWS/EBS"
    },
    {
      additional_statistics = ["p75", "p99"],
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
      metric_name           = "FirstByteLatency",
      namespace             = "AWS/S3"
    },
  ]
}
