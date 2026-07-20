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
| [aws_kms_alias.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias"></a> [alias](#input\_alias) | Alias name for the KMS key (without alias/ prefix) | `string` | `""` | no |
| <a name="input_customer_master_key_spec"></a> [customer\_master\_key\_spec](#input\_customer\_master\_key\_spec) | KMS key spec (e.g. SYMMETRIC\_DEFAULT, RSA\_2048) | `string` | `"SYMMETRIC_DEFAULT"` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Number of days before the KMS key is deleted after destruction | `number` | `7` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the KMS key | `string` | `"Parameter Store KMS master key"` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Whether automatic key rotation is enabled | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Whether the KMS key resource is created | `bool` | `true` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether the KMS key is enabled | `bool` | `true` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | Intended use of the KMS key (e.g. ENCRYPT\_DECRYPT) | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Key policy JSON document | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | ARN of the KMS key alias |
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | Name of the KMS key alias |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | ARN of the KMS key |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | ID of the KMS key |
<!-- END_TF_DOCS -->