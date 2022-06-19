variable "firehose_stream" {
  description = "AWS Kinesis firehose delivery stream name"
  type        = string
}

variable "privatekey" {
  description = "Coralogix account logs private key"
  sensitive   = true

}

variable "endpoint_region" {
  description = "Coralogix account region: us, singapore, ireland, india, stockholm"
}

variable "endpoint_url" {
  description = "Firehose Coralogix endpoint"
  type        = map(any)
  default = {
    "us" = {
      url   = "https://firehose-ingress.coralogix.us/firehose"
    }
    "singapore" = {
      url   = "https://firehose-ingress.coralogixsg.com/firehose"
    }
    "ireland" = {
      url   = "https://firehose-ingress.coralogix.com/firehose"
    }
    "india" = {
      url   = "https://firehose-ingress.coralogix.in/firehose"
    }
    "stockholm" = {
      url   = "https://firehose-ingress.eu2.coralogix.com/firehose"
    }
  }
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

variable "output_format" {
  description = "The output format of the cloudwatch metric stream: 'json' or 'opentelemetry0.7'"
  type = string
  default = "opentelemetry0.7"
}

variable "integration_type" {
  description = "The integration type of the firehose delivery stream: 'CloudWatch_Metrics_JSON' or 'CloudWatch_Metrics_OpenTelemetry070'"
  type = string
  default = "CloudWatch_Metrics_OpenTelemetry070"
}
