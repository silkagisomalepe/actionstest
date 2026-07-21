output "secret_arn" {
  value = aws_secretsmanager_secret.secret.arn
}

output "kms_key_arn" {
  value = module.kms_key.key_arn
}
