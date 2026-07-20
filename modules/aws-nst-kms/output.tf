output "key_arn" {
  description = "ARN of the KMS key"
  value       = join("", aws_kms_key.default[*].arn)
}

output "key_id" {
  description = "ID of the KMS key"
  value       = join("", aws_kms_key.default[*].key_id)
}

output "alias_arn" {
  description = "ARN of the KMS key alias"
  value       = join("", aws_kms_alias.default[*].arn)
}

output "alias_name" {
  description = "Name of the KMS key alias"
  value       = join("", aws_kms_alias.default[*].name)
}
