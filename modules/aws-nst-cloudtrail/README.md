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
| [aws_cloudtrail.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_iam_policy.cloudtrail_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cloudwatch_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudtrail_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail_bucket_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.aws_cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_bucket"></a> [access\_logs\_bucket](#input\_access\_logs\_bucket) | Access logs bucket | `string` | `""` | no |
| <a name="input_cloudtrail_lifecycle_bucket"></a> [cloudtrail\_lifecycle\_bucket](#input\_cloudtrail\_lifecycle\_bucket) | CloudTrail lifecycle duration in days | `number` | `90` | no |
| <a name="input_enable_log_file_validation"></a> [enable\_log\_file\_validation](#input\_enable\_log\_file\_validation) | Whether CloudTrail log file integrity validation is enabled | `bool` | `true` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Whether CloudTrail logging is enabled | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment environment | `string` | `""` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Whether to include global service events such as IAM | `bool` | `true` | no |
| <a name="input_is_multi_region_trail"></a> [is\_multi\_region\_trail](#input\_is\_multi\_region\_trail) | Whether the trail is a multi-region trail | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for CloudTrail resources | `string` | `""` | no |
| <a name="input_service_tags"></a> [service\_tags](#input\_service\_tags) | Additional tags to merge onto all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_arn"></a> [cloudtrail\_arn](#output\_cloudtrail\_arn) | ARN of the CloudTrail trail |
| <a name="output_cloudtrail_home_region"></a> [cloudtrail\_home\_region](#output\_cloudtrail\_home\_region) | Home region of the CloudTrail trail |
| <a name="output_cloudtrail_id"></a> [cloudtrail\_id](#output\_cloudtrail\_id) | ID of the CloudTrail trail |
| <a name="output_cloudtrail_log_group_name"></a> [cloudtrail\_log\_group\_name](#output\_cloudtrail\_log\_group\_name) | Name of the CloudWatch log group for CloudTrail |
<!-- END_TF_DOCS -->