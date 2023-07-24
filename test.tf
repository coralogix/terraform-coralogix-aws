module "resource-metadata" {
  source = "./modules/resource-metadata"

  coralogix_region    = "Custom"
  custom_url = "ingress.staging.coralogix.net:443"
  private_key         = "743e8f3a-3f0f-7daa-d7b5-19fac2492895"
  ssm_enable          = "True"
  layer_arn           = "arn:aws:lambda:us-east-1:035955823196:layer:coralogix-ssmlayer:21"
}