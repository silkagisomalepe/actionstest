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
| [aws_cloudwatch_log_group.loggroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create the CloudWatch log group | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key ID for encrypting the log group | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the CloudWatch log group | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for the CloudWatch log group name | `string` | `null` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Number of days to retain log events (null = never expire) | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | ARN of the CloudWatch log group |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch log group |
<!-- END_TF_DOCS -->