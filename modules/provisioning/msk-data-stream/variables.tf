variable "aws_region" {
  type        = string
  description = "The AWS region that you want to create the MSK in, Must be the same as the AWS region where your coralogix account is set"
  validation {
    condition     = contains(["eu-west-1", "eu-north-1", "ap-southeast-1", "ap-south-1", "us-east-2", "us-west-2", ""], var.aws_region)
    error_message = "The aws region must be one of these values: [eu-west-1, eu-north-1, ap-southeast-1, ap-south-1, us-east-2, us-west-2]."
  }
}

variable "cluster_name" {
  default     = "coralogix-msk-cluster"
  type        = string
  description = "The name of the MSK cluster"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC in formate of 10.0.0.0/20"
  default     = null
}

variable "subnet_cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks for the subnets in formate of [10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24]"
  default     = null
}

variable "msk_storage_volume_size" {
  type        = number
  description = "The size of the storage volume for the MSK brokers"
  default     = 1000
}

variable "instance_type" {
  type        = string
  description = "The instance type for the MSK brokers"
  default     = "kafka.m5.large"
}

variable "coraloigx_roles_arn_mapping" {
  type = map
  default = {
      "eu-west-1"      = "arn:aws:iam::625240141681:role/msk-access-eu1"
      "eu-north-1"     = "arn:aws:iam::625240141681:role/msk-access-eu2"
      "ap-southeast-1" = "arn:aws:iam::625240141681:role/msk-access-ap2"
      "ap-south-1"     = "arn:aws:iam::625240141681:role/msk-access-ap1"
      "us-east-2"      = "arn:aws:iam::625240141681:role/msk-access-us1"
      "us-west-2"      = "arn:aws:iam::739076534691:role/msk-access-us2"
      ""               = "arn:aws:iam::625240141681:role/msk-access-eu1"
  }
}
