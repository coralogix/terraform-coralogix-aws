module "s3-archive" {
  source = "./modules/provisioning/s3-archive"

#   aws_region    = "eu-north-1"
# bypass_valid_region = "us-east-1"
  logs_bucket_name    = "gr-test326245"
}