variable "private_key" {
  description = "The Coralogix private key which is used to validate your authenticity"
  type        = string
  sensitive   = true
}

variable "log_groups" {
  description = "The names of the CloudWatch log groups to watch"
  type        = list(string)
}
