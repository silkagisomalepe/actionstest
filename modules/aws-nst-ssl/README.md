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
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns"></a> [dns](#input\_dns) | DNS name | `string` | n/a | yes |
| <a name="input_service_tags"></a> [service\_tags](#input\_service\_tags) | Resource tags | `map(string)` | `{}` | no |
| <a name="input_verification"></a> [verification](#input\_verification) | Verification type | `string` | `"DNS"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cert_status"></a> [cert\_status](#output\_cert\_status) | n/a |
| <a name="output_ssl_cert_arn"></a> [ssl\_cert\_arn](#output\_ssl\_cert\_arn) | n/a |
<!-- END_TF_DOCS -->