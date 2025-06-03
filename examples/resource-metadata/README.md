# resource-metadata:

Manage the application which retrieves `meta data` from aws region and sends it to your *Coralogix* account.

## Usage

### Basic Usage (Direct API Key)

```hcl
provider "aws" {
}

module "resource-metadata" {
  source = "coralogix/aws/coralogix//modules/resource-metadata"

  coralogix_region    = "Europe"
  private_key         = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
}
```

### Secret Manager Usage (Create New Secret)

```hcl
provider "aws" {
}

# Deploy the lambda layer first (required for secret manager)
module "lambda-secretLayer" {
  source = "coralogix/aws/coralogix//modules/lambda-secretLayer"

}
module "resource-metadata" {
  source = "coralogix/aws/coralogix//modules/resource-metadata"
  depends_on = [module.lambda-secretLayer]

  coralogix_region        = "Europe"
  private_key             = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  secret_manager_enabled  = true
  create_secret          = true
  layer_arn              = module.lambda-secretLayer.lambda_layer_version_arn
}
```

### Secret Manager Usage (Existing Secret)

```hcl
provider "aws" {
}

# Deploy the lambda layer first (required for secret manager)
module "lambda-secretLayer" {
  source = "coralogix/aws/coralogix//modules/lambda-secretLayer"
}

module "resource-metadata" {
  source = "coralogix/aws/coralogix//modules/resource-metadata"
  depends_on = [module.lambda-secretLayer]

  coralogix_region        = "Europe"
  private_key             = "my-existing-secret-name"  # or full ARN
  secret_manager_enabled  = true
  create_secret          = false
  layer_arn              = module.lambda-secretLayer.lambda_layer_version_arn
}
```

## Deployment

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.

**Note**: When using Secret Manager, you need to deploy one `lambda-secretLayer` per AWS region. The layer provides the wrapper functionality needed for the Lambda function to retrieve secrets from AWS Secrets Manager.
