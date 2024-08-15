variable "aws_region" {
  type        = string
  description = "The AWS region that you want to create the MSK in, Must be the same as the AWS region where your coralogix account is set"
  validation {
    condition     = contains(["eu-west-1", "eu-north-1", "ap-southeast-1", "ap-south-1", "us-east-2", "us-west-2", ""], var.aws_region)
    error_message = "The aws region must be one of these values: [eu-west-1, eu-north-1, ap-southeast-1, ap-south-1, us-east-2, us-west-2]."
  }
}

variable "cluster_name" {
  default = "coralogix-msk-cluster"
  type = string
  description = "The name of the MSK cluster"
}

variable "aws_role_region"  {
  type = map
  default = {
      "eu-west-1"="eu1"
      "eu-north-1"="eu2"
      "ap-southeast-1"="ap2"
      "ap-south-1"="ap1"
      "us-east-2"="us1"
      "us-west-2"="us2"
  }
}