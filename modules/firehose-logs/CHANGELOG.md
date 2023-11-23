# Changelog

## firehose-logs

### 0.0.1 / 17.8.23
* [Update] fix duplicate IAM issue

### 0.0.1 / 5.9.23
* [Update] fix firehose policy management
* [Update] fix readme links for firehose logs and metric examples

### 0.0.1 / 28.9.23
* [Update] added subsystem to commonattributes for firehose metrics, add override_default_tags variable

### 0.0.1 / 16.10.23
* [Update] remove dynamic_metadata_logs, changed applicationNameDefault and subsystemNameDefault in following the changes made on firehose logs documentation.
* [Update] added `lambda_processor_enable` variable to enable/disable lambda transformation processor

### 0.0.1 / 25 10 23
* [Update] Migrate transformation Lambda runtime

### 0.0.2 / 22.11.23
* [Update] firehose split logs and metrics
* [Update] add to metrics CloudWatch_Metrics_OpenTelemetry070_WithAggregations
* [Update] configure to coralogix domain based
