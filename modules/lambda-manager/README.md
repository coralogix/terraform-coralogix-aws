# Coralogix-Lambda-Manager

This Lambda Function was created to pick up newly created and existing log groups and attach them to Firehose or Lambda integration

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.15.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Version |
|------|---------|
| <a name="module_terraform_aws_modules_lambda_aws"></a> [terraform-aws-modules/lambda/aws](#module\_terraform\_aws\_modules\_lambda\_aws) | >= 3.3.1 |

## Environment variables:

| Parameter | Description | Default Value | Required |
|---|---|---|---|
| regex_pattern | Set up this regex to match the Log Groups names that you want to automatically subscribe to the destination| | yes |
| logs_filter | Subscription filter to select which logs needs to be sent to Coralogix. For Example for Lambda Errors that are not sendable by Coralogix Lambda Layer '?REPORT ?"Task timed out" ?"Process exited before completing" ?errorMessage ?"module initialization error:" ?"Unable to import module" ?"ERROR Invoke Error" ?"EPSAGON_TRACE:"'. | | yes |
| destination_arn | Arn for the firehose to subscribe the log groups (By default is the firehose created by Serverless Template) | | yes |
| destination_role | Arn for the role to allow destination subscription to be pushed (Lambda or Firehose) | | yes |
| destination_type | Type of destination (Lambda or Firehose) | | yes |
| scan_old_loggroups | This will scan all LogGroups in the account and apply the subscription configured, will only run Once and set to false. Default is false | false | yes |
| architecture | Lambda function architecture, possible options are [x86_64, arm64] | x86_64 | |
| memory_size | The maximum allocated memory this lambda may consume. Default value is the minimum recommended setting please consult coralogix support before changing. | 1024 |  |
| timeout | The maximum time in seconds the function may be allowed to run. Default value is the minimum recommended setting please consult coralogix support before changing. | 300 |  |
| notification_email | Failure notification email address | | |

## Requirements

### Firehose
We are assuming you deployed our Firehose integration per our integration https://coralogix.com/docs/aws-firehose/

Firehose Destination requires a Role to allow Cloudwatch to send logs to Firehose. For that please verify that the role you are using in DESTINATION_ROLO has the following definitions.

Make sure that you put it the **Resource** field the arn for the destination firehose
Permissions policy

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch",
                "firehose:UpdateDestination"
            ],
            "Resource": <destination firehose arn>,
            "Effect": "Allow"
        }
    ]
}
```

Trust relationships

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CloudwatchToFirehoseRole",
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

### Lambda

Lambda destination does not need a specific role, but please check that the execution role of the destination lambda has the following resource based policy.

Make sure that you have replaced the **Resource** to the arn of the lambda, and the account_id with your account id in the **ArnLike**

```
{
 "Sid": "allow-logs-to-trigger",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.amazonaws.com"
      },
      "Action": "lambda:InvokeFunction",
      "Resource": <arn for the destination lambda>,
      "Condition": {
        "ArnLike": {
          "AWS:SourceArn": "arn:aws:logs:us-east-1:<account_id>:log-group:*:*"
        }
      }
}
```

## License

This project is licensed under the Apache-2.0 License.