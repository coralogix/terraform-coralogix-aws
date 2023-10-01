## Coralogx Layer for SM private_key

This Lambda Layer allows to store Coralogix Private Key in SM. 

You will need to deploy one layer per AWS Region you want to use. For now.

## Requirements 

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.17.1 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.17.1 |

## Outputs

lambda_layer_version_arn --> the arn on the lambde layer.
