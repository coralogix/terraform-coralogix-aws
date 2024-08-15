provider "aws" {
}

module "Msk-connection-module" {
  source = "coralogix/aws/coralogix//modules/provisioning/MSK-connection"

  aws_region      = "<your aws region>"
  cluster_name    = "<your bucket name>"

}