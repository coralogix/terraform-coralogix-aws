# Test ECS/EC2 OTEL collector

## Prereqs

* Setup ECS cluster on EC2.
* Setup AWS profile, or AWS session environment variables including ```AWS_DEFAULT_REGION```.
* Configure a "terraform.tfvars" accordingly from [./terraform.tfvars.template](./terraform.tfvars.template).

## Test provisioning ECS/EC2 OTEL collector

```
terraform plan
terraform apply
```

Expected results:
* ECS Service ```coralogix-otel-agent-<UUID>``` runs as a Daemon on every EC2 cluster node.
* Logs, traces, and metrics, are captured at your Coralogix endpoint.

## Test using local custom config file.

To test with an optional local custom config file, e.g. [./local_config.yaml](./local_config.yaml):

```
terraform plan -var="otel_config_file=local_config.yaml"
terraform apply -var="otel_config_file=local_config.yaml"
```

Expected results:
* OTEL_CONFIG environment variable is set to the contents of the local configuration file.

## Test using custom config file from Parameter Store.

To test with an optional custom configuration stored in Parameter Store:
* Create a Parameter Store in AWS for your configuration and a Role with access to it.
    * Example TF for creating test resources is available in [resources](./resources/)
* Edit [ps_config.vars](./ps_config.vars) to include the Parameter Store name and Task Execution Role ARN with access to the Parameter Store.

```
terraform plan -var-file="ps_config.vars"
terraform apply -var-file="ps_config.vars"
```

Expected results:
* OTEL_CONFIG environment variable is set to the Parameter Store defined above.

## Test using Secret API Key.

To test with a Secret API Key:
* Create a Secrets Manager Secret for your API Key and a Role with access to it.
    * Example TF for creating test resources is available in [resources](./resources/)
* Edit [secret_api_key.vars](./secret_api_key.vars) to include the Secret ARN and Task Execution Role ARN with access to the Secret.

```
terraform plan -var-file="secret_api_key.vars"
terraform apply -var-file="secret_api_key.vars"
```

Expected results:
* PRIVATE_KEY environment variable is set to the Secret defined above.

## Test custom domain

To test using an optional custom Coralogix domain, such as a [Private Link Endpoint](https://coralogix.com/docs/coralogix-amazon-web-services-aws-privatelink-endpoints/).

```
terraform plan -var="custom_domain=your-custom-domain.com"
terraform apply -var="custom_domain=your-custom-domain.com"
```

Expected results:
* Logs, traces, and metrics, are captured at the specified Coralogix domain.

## Test de-provisioning ECS/EC2 OTEL collector

```
terraform destroy <Any of your test variables or files>
```

Expected results:
* ECS Service ```coralogix-otel-agent``` is removed from the ECS cluster.
