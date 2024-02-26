module "lambda-manager" {
  source = "coralogix/aws/coralogix//modules/lambda-manager"

  regex_pattern    = ".*"
  destination_arn  = "arn:aws:lambda:us-east-1:12345678910:function:*"
  logs_filter      = "custome-test"
  destination_role = "arn:aws:iam::12345678910:role/role_name"
  destination_type = "lambda"
}