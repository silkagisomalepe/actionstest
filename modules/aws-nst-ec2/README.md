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
| [aws_autoscaling_group.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_iam_instance_profile.server_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ec2_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.server_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ec2"></a> [ec2](#input\_ec2) | List of EC2 instance configurations | <pre>list(object({<br/>    name                   = string<br/>    type                   = string<br/>    ami                    = string<br/>    subnet_id              = string<br/>    vpc_zone_subnet_ids    = list(string)<br/>    volume_size            = number<br/>    security_group_ids     = list(string)<br/>    target_group_arns      = list(string)<br/>    user_data              = optional(string, "")<br/>    alerts_topic_arn       = string<br/>    enable_ssm             = optional(bool, true)<br/>    enable_autoscaling     = optional(bool, false)<br/>    desired_capacity       = optional(number, 1)<br/>    min_size               = optional(number, 1)<br/>    max_size               = optional(number, 1)<br/>    target_cpu_utilization = optional(number, 70)<br/>  }))</pre> | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Service name prefix for shared resources | `string` | n/a | yes |
| <a name="input_additional_policy_arns"></a> [additional\_policy\_arns](#input\_additional\_policy\_arns) | Extra IAM policy ARNs to attach to the instance role (e.g. artifact bucket read access) | `list(string)` | `[]` | no |
| <a name="input_ansible_artifact_bucket"></a> [ansible\_artifact\_bucket](#input\_ansible\_artifact\_bucket) | S3 bucket to pull the latest Ansible deployment bundle from at boot. Empty disables the pull-based bootstrap. | `string` | `""` | no |
| <a name="input_ansible_artifact_key"></a> [ansible\_artifact\_key](#input\_ansible\_artifact\_key) | S3 key of the Ansible deployment bundle to pull at boot | `string` | `"dev/ansible-deploy.zip"` | no |
| <a name="input_service_tags"></a> [service\_tags](#input\_service\_tags) | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group_names"></a> [autoscaling\_group\_names](#output\_autoscaling\_group\_names) | Map of instance name to autoscaling group name |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | IAM role name for EC2 instances |
| <a name="output_launch_template_ids"></a> [launch\_template\_ids](#output\_launch\_template\_ids) | Map of instance name to launch template ID |
<!-- END_TF_DOCS -->