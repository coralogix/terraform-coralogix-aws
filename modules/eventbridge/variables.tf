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
  description = "The Coralogix location region, possible options are [EU1, EU2, AP1, AP2, AP3, US1, US2]"
  type        = string
  validation {
    condition     = contains(["EU1", "EU2", "AP1", "AP2", "AP3", "US1", "US2", "ireland", "india", "stockholm", "singapore", "us", "us2", "Custom"], var.coralogix_region)
    error_message = "The coralogix region must be one of these values: [EU1, EU2, AP1, AP2, AP3, US1, US2, Custom]."
  }
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

variable "detail_type" {
  description = "AWS eventbridge detail type"
  type        = list(string)
  default     = null
}

variable "additional_headers" {
  type = list(object({
    key   = string
    value = string
  }))
  description = "Additional headers to send in API destination"
  default     = []
}