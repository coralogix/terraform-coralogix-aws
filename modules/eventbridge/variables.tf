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
  description = "Custom Coralogix domain. Required when coralogix_region is set to 'Custom'."
  type        = string
  default     = null
  validation {
    condition     = var.coralogix_region != "Custom" || (var.custom_url != null && var.custom_url != "")
    error_message = "custom_url must be set when coralogix_region is 'Custom'."
  }
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

variable "iam_path" {
  description = "Path under which to create IAM roles and policies (e.g. \"/coralogix/\"). Defaults to the AWS default \"/\"."
  type        = string
  default     = null
  validation {
    condition     = var.iam_path == null || can(regex("^(/|/[\\x21-\\x7F]+/)$", var.iam_path))
    error_message = "iam_path must be null, \"/\", or a string that begins and ends with a forward slash (/)."
  }
}
