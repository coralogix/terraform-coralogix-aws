# msk data stream

The module will create an MSK with the dependency, the MSK will allow Coralogix to send telemetry data to his topics.

The module can run only on the following regions eu-west-1,eu-north-1,ap-southeast-1,ap-south-1,us-east-2.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

### To run the module
```hcl
provider "aws" {
}

module "Msk-data-stream-module" {
  source = "coralogix/aws/coralogix//modules/provisioning/msk-data-stream"

  aws_region      = "<your aws region>"
}
```