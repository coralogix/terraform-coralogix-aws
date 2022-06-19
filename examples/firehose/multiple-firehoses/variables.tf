variable "coralogix_streams" {
  type = list(string)
  default = ["json-to-eu2"]
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
