module "kms_key" {
  source                  = "../aws-nst-kms"
  description             = "secrets-manager-kms-key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  alias                   = "alias/${var.name}-secret-key"
  policy                  = data.aws_iam_policy_document.kms_secrets_manager.json
}

resource "aws_secretsmanager_secret" "secret" {
  name        = var.name
  description = var.description
  kms_key_id  = module.kms_key.key_arn
  tags = merge(
    var.service_tags, {
      Name = var.name
  })
}

resource "aws_secretsmanager_secret_version" "secret" {
  count = var.secret_string != null ? 1 : 0

  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret_string

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret_rotation" "secret" {
  count = var.rotation_lambda_arn != null ? 1 : 0

  secret_id           = aws_secretsmanager_secret.secret.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}
