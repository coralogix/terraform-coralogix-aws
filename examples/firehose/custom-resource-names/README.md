# Firehose Delivery Stream with custom resource names
Configuration in this directory creates a firehose delivery stream, and a CloudWatch metrics stream. Related resources are however named differently than the default naming convention of using `firehose_stream`.

## Example

```
cloudwatch_metric_stream_custom_name  = "test_cloudwatch_metric_stream_for_example"
s3_backup_custom_name                 = "test_s3_backup_custom_name_for_example"
lambda_processor_custom_name          = "test_lambda_processor_custom_name_for_example"
```