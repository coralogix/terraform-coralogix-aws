variable "coralogix_streams" {
  type = list(string)
  default = ["stream-1", "stream-2"]
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
