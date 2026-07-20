<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_detector.detector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_detector_feature.ebs_malware_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature) | resource |
| [aws_guardduty_detector_feature.eks_audit_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature) | resource |
| [aws_guardduty_detector_feature.lambda_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature) | resource |
| [aws_guardduty_detector_feature.runtime_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature) | resource |
| [aws_guardduty_detector_feature.s3_data_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector_feature) | resource |
| [aws_guardduty_publishing_destination.guard_duty_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_publishing_destination) | resource |
| [aws_kms_alias.guard_duty_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.guard_duty_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.guard_duty_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.guard_duty_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.guard_duty_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.guard_duty_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.guard_duty_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail_alarm_bucket_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.guard_duty_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.guard_duty_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_bucket"></a> [access\_logs\_bucket](#input\_access\_logs\_bucket) | Access logs bucket | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Envrionment environment | `string` | `""` | no |
| <a name="input_guardduty_lifecycle_days"></a> [guardduty\_lifecycle\_days](#input\_guardduty\_lifecycle\_days) | S3 Bucket for GuardDuty Lifecycle Logs | `number` | `365` | no |
| <a name="input_service_tags"></a> [service\_tags](#input\_service\_tags) | Additional tags to merge onto all resources | `map(string)` | `{}` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Client Name for use as a prefix | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_guardduty_detector_id"></a> [guardduty\_detector\_id](#output\_guardduty\_detector\_id) | ARN of the GuardDuty detector |
| <a name="output_guardduty_s3_bucket_arn"></a> [guardduty\_s3\_bucket\_arn](#output\_guardduty\_s3\_bucket\_arn) | ARN of the S3 bucket for GuardDuty findings |
<!-- END_TF_DOCS -->