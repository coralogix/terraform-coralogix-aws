variable "coralogix_company_id" {
  description = "Coralogix company ID, used for security validation. Found in Settings > Send Your Data > Company ID"
  type        = string
}


variable "external_id_secret" {
  description = "ExternalIdSecret for sts:AssumeRole. Use a random value."
  type        = string

  validation {
    condition     = length(var.external_id_secret) >= 2 && length(var.external_id_secret) <= 1224 && can(regex("^[A-Za-z0-9+=,\\.@:/-]+$", var.external_id_secret))
    error_message = "The external_id_secret must be 2-1224 characters long and may only contain alphanumeric characters and the symbols +, =, ,, ., @, :, /, - (no whitespace allowed)."
  }
}

variable "coralogix_region" {
  description = "Location of Coralogix account."
  type        = string
  default     = "US2"
  validation {
    condition     = contains(["dev", "staging", "EU1", "EU2", "AP1", "AP2", "AP3", "US1", "US2"], var.coralogix_region)
    error_message = "The coralogix_region must be one of: dev, staging, EU1, EU2, AP1, AP2, AP3, US1, US2."
  }
}

variable "custom_coralogix_region" {
  description = "location of coralogix account."
  type        = string
  default     = ""
}

variable "role_name" {
  description = "The name of the AWS IAM Role that will be created. Must be at most 64 characters and may only contain alphanumeric characters and the symbols +, =, ,, ., @, _, -."
  type        = string
  default     = "coralogix-aws-metrics-integration-role"

  validation {
    condition     = length(var.role_name) <= 64 && can(regex("^[A-Za-z0-9+=,\\.@_-]+$", var.role_name))
    error_message = "role_name must be at most 64 characters and may only contain alphanumeric characters and the symbols +, =, ,, ., @, _, -."
  }
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
