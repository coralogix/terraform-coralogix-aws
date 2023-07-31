variable "eventbridge_stream" {
  description = "AWS eventbridge delivery stream name"
  type        = string
}

variable "role_name" {
  type        = string
  description = "The name of the eventbridge role"
}

variable "private_key" {
  type        = string
  description = "Your Coralogix private key"
  sensitive   = true
}

variable "coralogix_region" {
  description = "Coralogix account region: us, us2, singapore, ireland, india, stockholm, custom [in lower-case letters]"
}

variable "custom_url" {
  description = "Custom coralogix url"
  type        = string
  default     = ""
}

variable "sources" {
  type        = list(any)
  description = "The services for which we will send events"
  default     = ["aws.ec2", "aws.autoscaling", "aws.cloudwatch", "aws.events", "aws.health", "aws.rds"]
}

variable "application_name" {
  description = "Coralogix application name"
  type        = string
  default     = null
}
variable "policy_name" {
  description = "AWS IAM policy name"
  type        = string
  default     = "EventBridge_policy"
}
