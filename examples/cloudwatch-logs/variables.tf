variable "private_key" {
  description = "The Coralogix private key which is used to validate your authenticity"
  type        = string
  sensitive   = true
}

variable "log_group" {
  description = "The name of the CloudWatch log group to watch"
  type        = string
}
