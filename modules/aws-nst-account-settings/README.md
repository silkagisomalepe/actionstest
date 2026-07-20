<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.0 |
| <a name="requirement_awsutils"></a> [awsutils](#requirement\_awsutils) | >= 0.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_awscc.awscccurrent"></a> [awscc.awscccurrent](#provider\_awscc.awscccurrent) | >= 1.0 |
| <a name="provider_awsutils"></a> [awsutils](#provider\_awsutils) | >= 0.20.0 |

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_plan.monthly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_plan.weekly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_selection.monthly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_selection.weekly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_budgets_budget.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |
| [aws_ebs_default_kms_key.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_default_kms_key) | resource |
| [aws_ebs_encryption_by_default.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_ebs_encryption_by_default.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_ec2_image_block_public_access.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_image_block_public_access) | resource |
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_account_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |
| [aws_sns_topic.technical_alerts_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.technical_alerts_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.technical_alerts_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [awscc_ec2_snapshot_block_public_access.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/ec2_snapshot_block_public_access) | resource |
| [awsutils_default_vpc_deletion.current](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/default_vpc_deletion) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_users_to_change_password"></a> [allow\_users\_to\_change\_password](#input\_allow\_users\_to\_change\_password) | Whether IAM users are allowed to change their own password | `bool` | `true` | no |
| <a name="input_backup_completion_window"></a> [backup\_completion\_window](#input\_backup\_completion\_window) | Minutes after a backup job is successfully started before it must complete, or it is cancelled | `number` | `120` | no |
| <a name="input_backup_start_window"></a> [backup\_start\_window](#input\_backup\_start\_window) | Minutes after a backup job is scheduled before it must start, or it is cancelled | `number` | `60` | no |
| <a name="input_budget_alerts_emails"></a> [budget\_alerts\_emails](#input\_budget\_alerts\_emails) | Email addresses for 50% and 100% budget alerts (actual and forecasted) | `list(string)` | `[]` | no |
| <a name="input_budget_alerts_escalations_emails"></a> [budget\_alerts\_escalations\_emails](#input\_budget\_alerts\_escalations\_emails) | Email addresses for 150% budget escalation alerts (actual and forecasted) | `list(string)` | `[]` | no |
| <a name="input_budget_name"></a> [budget\_name](#input\_budget\_name) | Budget name | `string` | `"budget"` | no |
| <a name="input_budget_type"></a> [budget\_type](#input\_budget\_type) | Budget type | `string` | `"COST"` | no |
| <a name="input_daily_backup_plan"></a> [daily\_backup\_plan](#input\_daily\_backup\_plan) | Cron schedule for daily backup plan | `string` | `"cron(0 1 * * ? *)"` | no |
| <a name="input_daily_backup_plan_delete_after"></a> [daily\_backup\_plan\_delete\_after](#input\_daily\_backup\_plan\_delete\_after) | Days after which daily backups are deleted | `number` | `14` | no |
| <a name="input_daily_backup_plan_move_to_cold_storage"></a> [daily\_backup\_plan\_move\_to\_cold\_storage](#input\_daily\_backup\_plan\_move\_to\_cold\_storage) | Days after which daily backups are moved to cold storage (0 = disabled) | `number` | `0` | no |
| <a name="input_delete_default_vpc"></a> [delete\_default\_vpc](#input\_delete\_default\_vpc) | Whether to delete the default VPC in the current region | `bool` | `false` | no |
| <a name="input_hard_expiry"></a> [hard\_expiry](#input\_hard\_expiry) | Whether to prevent IAM users from resetting an expired password | `bool` | `false` | no |
| <a name="input_include_credit"></a> [include\_credit](#input\_include\_credit) | Budget include credit | `bool` | `false` | no |
| <a name="input_include_discount"></a> [include\_discount](#input\_include\_discount) | Budget include discount | `bool` | `false` | no |
| <a name="input_include_other_subscription"></a> [include\_other\_subscription](#input\_include\_other\_subscription) | Budget include other subscription | `bool` | `true` | no |
| <a name="input_include_recurring"></a> [include\_recurring](#input\_include\_recurring) | Budget include recurring | `bool` | `true` | no |
| <a name="input_include_refund"></a> [include\_refund](#input\_include\_refund) | Budget include refund | `bool` | `false` | no |
| <a name="input_include_subscription"></a> [include\_subscription](#input\_include\_subscription) | Budget include subscription | `bool` | `true` | no |
| <a name="input_include_support"></a> [include\_support](#input\_include\_support) | Budget include support | `bool` | `true` | no |
| <a name="input_include_tax"></a> [include\_tax](#input\_include\_tax) | Budget include tax | `bool` | `true` | no |
| <a name="input_include_upfront"></a> [include\_upfront](#input\_include\_upfront) | Budget include upfront | `bool` | `true` | no |
| <a name="input_limit_amount"></a> [limit\_amount](#input\_limit\_amount) | Budget limit amount in USD | `number` | `0` | no |
| <a name="input_limit_unit"></a> [limit\_unit](#input\_limit\_unit) | Budget limit unit | `string` | `"USD"` | no |
| <a name="input_max_password_age"></a> [max\_password\_age](#input\_max\_password\_age) | Number of days before an IAM user password expires | `number` | `90` | no |
| <a name="input_minimum_password_length"></a> [minimum\_password\_length](#input\_minimum\_password\_length) | Minimum number of characters allowed in an IAM user password | `number` | `16` | no |
| <a name="input_monthly_backup_plan"></a> [monthly\_backup\_plan](#input\_monthly\_backup\_plan) | Cron schedule for monthly backup plan | `string` | `"cron(0 3 1 * ? *)"` | no |
| <a name="input_monthly_backup_plan_delete_after"></a> [monthly\_backup\_plan\_delete\_after](#input\_monthly\_backup\_plan\_delete\_after) | Days after which monthly backups are deleted | `number` | `420` | no |
| <a name="input_monthly_backup_plan_move_to_cold_storage"></a> [monthly\_backup\_plan\_move\_to\_cold\_storage](#input\_monthly\_backup\_plan\_move\_to\_cold\_storage) | Days after which monthly backups are moved to cold storage (0 = disabled) | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | Prefix for AWS resources | `string` | `""` | no |
| <a name="input_password_reuse_prevention"></a> [password\_reuse\_prevention](#input\_password\_reuse\_prevention) | Number of previous passwords that IAM users are prevented from reusing | `number` | `24` | no |
| <a name="input_require_lowercase_characters"></a> [require\_lowercase\_characters](#input\_require\_lowercase\_characters) | Whether IAM user passwords must contain at least one lowercase character | `bool` | `true` | no |
| <a name="input_require_numbers"></a> [require\_numbers](#input\_require\_numbers) | Whether IAM user passwords must contain at least one numeric character | `bool` | `true` | no |
| <a name="input_require_symbols"></a> [require\_symbols](#input\_require\_symbols) | Whether IAM user passwords must contain at least one symbol character | `bool` | `true` | no |
| <a name="input_require_uppercase_characters"></a> [require\_uppercase\_characters](#input\_require\_uppercase\_characters) | Whether IAM user passwords must contain at least one uppercase character | `bool` | `true` | no |
| <a name="input_service_tags"></a> [service\_tags](#input\_service\_tags) | Resource tags | `map(string)` | `{}` | no |
| <a name="input_sns_subscriber_email"></a> [sns\_subscriber\_email](#input\_sns\_subscriber\_email) | Email address for SNS subscription | `string` | `""` | no |
| <a name="input_time_unit"></a> [time\_unit](#input\_time\_unit) | Budget time unit | `string` | `"MONTHLY"` | no |
| <a name="input_use_blended"></a> [use\_blended](#input\_use\_blended) | Budget use blended | `bool` | `true` | no |
| <a name="input_weekly_backup_plan"></a> [weekly\_backup\_plan](#input\_weekly\_backup\_plan) | Cron schedule for weekly backup plan | `string` | `"cron(0 2 ? * 6 *)"` | no |
| <a name="input_weekly_backup_plan_delete_after"></a> [weekly\_backup\_plan\_delete\_after](#input\_weekly\_backup\_plan\_delete\_after) | Days after which weekly backups are deleted | `number` | `120` | no |
| <a name="input_weekly_backup_plan_move_to_cold_storage"></a> [weekly\_backup\_plan\_move\_to\_cold\_storage](#input\_weekly\_backup\_plan\_move\_to\_cold\_storage) | Days after which weekly backups are moved to cold storage (0 = disabled) | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_technical_alerts_topic"></a> [technical\_alerts\_topic](#output\_technical\_alerts\_topic) | ARN of the SNS topic for technical alerts |
<!-- END_TF_DOCS -->