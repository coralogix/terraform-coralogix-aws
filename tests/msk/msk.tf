terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "msk" {
  source = "../../modules/msk"

    application_name   = "msk"
    msk_cluster_arn    = "arn:aws:kafka:us-east-1:035955823196:cluster/example-cluster/23ecc12b-98b3-4276-adf1-dabf51c39209-21"
    msk_stream         = "mks-stream"
    private_key        = "{{ secrets.TESTING_PRIVATE_KEY }}"
    subsystem_name     = "msk"
    topic              = "example-kafka-topic-1"
    notification_email = null
    ssm_enable         = "False"
    layer_arn          = "<your layer arn>"
}