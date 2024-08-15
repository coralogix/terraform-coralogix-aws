# 

The module 

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

### To run the module
```hcl
provider "aws" {
}

module "Msk-connection-module" {
  source = "coralogix/aws/coralogix//modules/provisioning/MSK-connection"

  aws_region      = "<your aws region>"
  cluster_name    = "<your bucket name>"
}
```