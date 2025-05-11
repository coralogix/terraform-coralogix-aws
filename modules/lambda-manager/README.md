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
|-----------|-------------|---------------|----------|
| regex_pattern | Set up this regex to match the Log Groups names that you want to automatically subscribe to the destination| | yes |
| logs_filter | Subscription filter to select which logs needs to be sent to Coralogix. For Example for Lambda Errors that are not sendable by Coralogix Lambda Layer '?REPORT ?"Task timed out" ?"Process exited before completing" ?errorMessage ?"module initialization error:" ?"Unable to import module" ?"ERROR Invoke Error" ?"EPSAGON_TRACE:"'. |  | no |
| log_group_permissions_prefix | A list of strings of log group prefixes. The code will use these prefixes to create permissions for the Lambda instead of creating for each log group permission it will use the prefix with a wild card to give the Lambda access for all of the log groups that start with these prefix. This parameter doesn't replace the regex_pattern parameter.  For more information, refer to the Note below.| | no |
| destination_arn | Arn for the firehose to subscribe the log groups (By default, is the firehose created by Serverless Template) | | yes |
| destination_role | Arn for the role to allow destination subscription to be pushed (In case you use Firehose) | n/a | no |
| destination_type | Type of destination (Lambda or Firehose) | | yes |
| scan_old_loggroups | This will scan all LogGroups in the account and apply the subscription configured, will only run Once and set to false. Default is false | false | yes |
| add_permissions_to_all_log_groups | When set to true, grants subscription permissions to the destination for all current and future log groups using a wildcard | false | |
| disable_add_permission | Disable add permission to loggroup| false | |
| architecture | Lambda function architecture, possible options are [x86_64, arm64] | x86_64 | |
| memory_size | The maximum allocated memory this lambda may consume. Default value is the minimum recommended setting please consult coralogix support before changing. | 1024 |  |
| timeout | The maximum time in seconds the function may be allowed to run. Default value is the minimum recommended setting please consult coralogix support before changing. | 300 |  |
| notification_email | Failure notification email address | | |

> [!Note]
> If the destination is a Lambda function, the code will identify log groups that match the specified `regex_pattern` and configure them as triggers for the destination Lambda. Each matching log group is also granted the necessary permission to invoke the Lambda.

> However, when dealing with a large number of log groups, this process may result in an error. This occurs because the code attempts to create a separate permission for each log group, and AWS imposes a limit on the number of permissions that can be attached to a single Lambda function.

> To address this limitation, the `log_group_permissions_prefix` parameter is used. Instead of creating individual permissions for each log group, this parameter allows you to assign a single wildcard-based permission to the Lambda function.

> For example, if you have the log groups log1, log2, and log3, setting `log_group_permissions_prefix = log` will generate one permission using a wildcard (e.g., log*) to cover all matching log groups. This avoids exceeding AWS's permission limit for a Lambda function.

> However, it's important to note that:
>
> - You must still set `regex_pattern = log.*` to match the desired log groups.
> - When using `log_group_permissions_prefix`, the log groups will not appear as individual triggers on the Lambda function in the AWS Console, although they will still be able to invoke it.

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
