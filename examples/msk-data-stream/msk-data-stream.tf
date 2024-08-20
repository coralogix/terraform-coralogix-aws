provider "aws" {
}

module "msk-data-stream-module" {
  source = "coralogix/aws/coralogix//modules/provisioning/msk-data-stream"

  aws_region      = "<your aws region>"
  cluster_name    = "<your bucket name>"

}