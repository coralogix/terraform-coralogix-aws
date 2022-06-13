variable "coralogix_firehose_stream_name" {
  description = "Coralogix firehose delivery stream name"
  type        = string
  default = "coralogix-firehose"
}

variable "coralogix_endpoint_url" {
  type        = string
  description = "Coralogix endpoint url"
  default = "https://firehose-ingress.eu2.coralogix.com/firehose"
}

variable "coralogix_privatekey" {
  type        = string
  description = "Coralogix account logs private key"
  sensitive = true
}

variable "enable_cloudwatch_metricstream" {
  type = bool
  description = "Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose"
  default = false
}