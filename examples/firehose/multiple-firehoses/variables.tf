variable "coralogix_streams" {
  type    = list(string)
  default = ["stream-1", "stream-2"]
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
