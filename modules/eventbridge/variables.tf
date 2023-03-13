
variable "eventbridge_stream" {
  description = "AWS eventbridge delivery stream name"
  type        = string
}
variable "role_name"{
  type = string
  description = "Name the role you want to use for the eventbridge"
}

variable "private_key" {
  type = string
  description = "Your Coralogix private key"
  sensitive   = true
}

variable "coralogix_region" {
  description = "Coralogix account region: us, singapore, ireland, india, stockholm [in lower-case letters]"
}

variable "sources" {
  type = list
  description = "The services you want to send there events"
  default =["aws.ec2","aws.s3","aws.health"]

  
}
variable "application_name" {
  description = "The application name of the metrics"
  type        = string
  default     = null
}