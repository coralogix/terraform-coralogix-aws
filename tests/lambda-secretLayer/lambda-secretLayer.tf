provider "aws" {
  region = "us-east-1"
}

module "lambda-secretLayer" {
  source = "../../modules/lambda-secretLayer"

}