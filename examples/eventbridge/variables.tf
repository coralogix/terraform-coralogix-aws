variable "coralogix_eventbridge_stream_name" {
  description = "Coralogix eventbridge delivery stream name"
  type        = string
  default     = "coralogix-eventbridge"
}

variable "coralogix_region" {
  type        = string
  description = "The region of the Coralogix account"
}

variable "coralogix_privatekey" {
  type        = string
  description = "Coralogix account private key"
  sensitive   = true
}

variable "eventbridge_role_name" {
  type = string
  description = "The name of the eventbridge role"
  default = "coralogix-eventbridge-role"
}

variable "eventbridge_sources" {
  type = list
  description = "The services for which we will send events"
  default =["aws.ec2"]  
}