# resource-metadata-sqs

Manage the application which retrieves resource metadata from all Lambda functions and EC2 instances in the target AWS region and sends it to your *Coralogix* account. This is an extended version of the [resource-metadata](../../modules/resource-metadata) module, which uses SQS to make the metadata generation process asynchronous in order to handle a large number of resources.

It's recommended to use this module for environments with more than 5000 Lambda functions (or EC2 instances) in the target AWS region.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {}

module "resource-metadata" {
  source = "coralogix/aws/coralogix//modules/resource-metadata-sqs"

  coralogix_region    = "EU2"
  api_key             = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  event_mode          = "EnabledCreateTrail"
}
```

and then execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.

## Cross-Account Collection

This example shows how to collect metadata from multiple AWS accounts using the IAM role with the trust relationship to the source account.

```hcl
provider "aws" {}

module "resource-metadata" {
  source = "coralogix/aws/coralogix//modules/resource-metadata-sqs"

  coralogix_region           = "EU2"
  api_key                    = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  source_regions             = ["eu-north-1", "eu-west-1", "us-east-1"]
  crossaccount_mode          = "StaticIAM"
  crossaccount_account_ids   = ["123456789012", "234567890123"]
  crossaccount_iam_role_name = "CrossAccountRoleForResourceMetadata"
}

resource "aws_iam_role" "cross_account_role" {
  provider = aws.source_account
  name = "CrossAccountRoleForResourceMetadata"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = [
            # comment those two lines before deploying the module
            module.resource-metadata.generator_lambda_function_role_arn,
            module.resource-metadata.collector_lambda_function_role_arn
          ]
        }
      }
    ]
  })

  inline_policy {
    name = "CoralogixResourceMetadata"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ec2:DescribeInstances",
            "lambda:ListFunctions", 
            "lambda:ListVersionsByFunction",
            "lambda:GetFunction",
            "lambda:ListAliases",
            "lambda:ListEventSourceMappings",
            "lambda:GetPolicy",
            "tag:GetResources"
          ]
          Resource = "*"
        }
      ]
    })
  }
}
```
