variable "eventbridge_stream" {
  description = "AWS eventbridge delivery stream name"
  type        = string
}

variable "role_name"{
  type = string
  description = "The name of the eventbridge role"
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
  description = "The services for which we will send events"
  default = ["aws.ec2","aws.autoscaling","aws.ecr","aws.s3","aws.cloudwatch","aws.events","aws.health","aws.rds"]
}

variable "application_name" {
  description = "Coralogix application name"
  type        = string
  default     = null
}