# Coralogix-Lambda-Manager

This Lambda Function was created to pick up newly created and existing log groups and attach them to Firehose or Lambda integration

Environment variables:

| Parameter | Description | Default Value | Required |
|---|---|---|---|
| regex_pattern | Set up this regex to match the Log Groups names that you want to automatically subscribe to the destination| | :heavy_check_mark: |
| logs_filter | Subscription filter to select which logs needs to be sent to Coralogix. For Example for Lambda Errors that are not sendable by Coralogix Lambda Layer '?REPORT ?"Task timed out" ?"Process exited before completing" ?errorMessage ?"module initialization error:" ?"Unable to import module" ?"ERROR Invoke Error" ?"EPSAGON_TRACE:"'. | | :heavy_check_mark: |
| destination_arn | Arn for the firehose to subscribe the log groups (By default is the firehose created by Serverless Template) | | :heavy_check_mark: |
| destination_role | Arn for the role to allow destination subscription to be pushed (Lambda or Firehose) | | :heavy_check_mark: |
| destination_type | Type of destination (Lambda or Firehose) | | :heavy_check_mark: |
| scan_old_loggroups | This will scan all LogGroups in the account and apply the subscription configured, will only run Once and set to false. Default is false | false | :heavy_check_mark: |
| architecture | Lambda function architecture, possible options are [x86_64, arm64] | x86_64 | |
| memory_size | The maximum allocated memory this lambda may consume. Default value is the minimum recommended setting please consult coralogix support before changing. | 1024 |  |
| timeout | The maximum time in seconds the function may be allowed to run. Default value is the minimum recommended setting please consult coralogix support before changing. | 300 |  |
| notification_email | Failure notification email address | | |

## Requirements

### Firehose
We are assuming you deployed our Firehose integration per our integration https://coralogix.com/docs/aws-firehose/

Firehose Destination requires a Role to allow Cloudwatch to send logs to Firehose. For that please verify that the role you are using in DESTINATION_ROLO has the following definitions.

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
            "Resource": "arn:aws:firehose:sa-east-1:771039649440:deliverystream/coralogixdeliverystream-sa-east-1",
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
                "Service": "logs.sa-east-1.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

### Lamba

Lambda destination does not need a specific role, but please check that the execution rolo of the destination lambda has the following resource based policy.

```
{
    "Sid": "lsdmvpsdf",
    "Effect": "Allow",
    "Principal": {
        Service": "logs.amazonaws.com"
    },
    "Action": "lambda:InvokeFunction",
    "Resource": "arn:aws:lambda:us-east-1:771039649440:function:coralogix-aws-shipper",
    "Condition": {
        "ArnLike": {
        "AWS:SourceArn": "arn:aws:logs:us-east-1:771039649440:*:*:*"
        }
    }
}
```

## License

This project is licensed under the Apache-2.0 License.