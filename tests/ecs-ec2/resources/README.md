# Test resources for ECS EC2 OTEL integration testing

The test_resources.tf file is used to create the resources needed to test the ECS/EC2 OTEL collector.

It will create a Parameter Store for your configuration and a Secrets Manager Secret for the API key. It will also create a Role with access to the Parameter Store and Secrets Manager. These resources can be used in the various tests.

## Prereqs

* Setup AWS profile, or AWS session environment variables including ```AWS_DEFAULT_REGION```.

## Deploy test resources

You can provide an "api_key" and "aws_region" on the CLI. If not provided, you will be prompted for them during your plan and apply phases.
```
terraform init
terraform plan
terraform apply
```

Expected results:
* The test resources will be created.
* Outputs with the ARN and names of your test resources will be displayed.

## Destroy test resources

```
terraform destroy
```

Expected results:
* The test resources will be removed from your AWS account.