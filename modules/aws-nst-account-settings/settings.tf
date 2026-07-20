resource "aws_iam_account_password_policy" "this" {
  allow_users_to_change_password = var.allow_users_to_change_password
  hard_expiry                    = var.hard_expiry
  max_password_age               = var.max_password_age
  minimum_password_length        = var.minimum_password_length
  password_reuse_prevention      = var.password_reuse_prevention
  require_lowercase_characters   = var.require_lowercase_characters
  require_numbers                = var.require_numbers
  require_uppercase_characters   = var.require_uppercase_characters
  require_symbols                = var.require_symbols
}

resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

resource "aws_ec2_image_block_public_access" "this" {
  state = "block-new-sharing"
}

resource "awscc_ec2_snapshot_block_public_access" "this" {
  provider = awscc.awscccurrent
  state    = "block-all-sharing"
}

resource "aws_budgets_budget" "this" {
  name         = var.budget_name
  budget_type  = var.budget_type
  limit_amount = var.limit_amount
  limit_unit   = var.limit_unit
  time_unit    = var.time_unit

  cost_types {
    include_credit             = var.include_credit
    include_discount           = var.include_discount
    include_other_subscription = var.include_other_subscription
    include_recurring          = var.include_recurring
    include_refund             = var.include_refund
    include_subscription       = var.include_subscription
    include_support            = var.include_support
    include_tax                = var.include_tax
    include_upfront            = var.include_upfront
    use_blended                = var.use_blended
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alerts_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alerts_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 150
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alerts_escalations_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alerts_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alerts_emails
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 150
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alerts_escalations_emails
  }
}

resource "aws_backup_vault" "this" {
  name        = "${var.name}-backup-vault"
  kms_key_arn = data.aws_kms_key.backup.arn
  tags = {
    Name = "${var.name}-backup-vault"
  }
}

resource "aws_backup_plan" "daily" {
  name = "${var.name}-daily-backup-plan"

  rule {
    rule_name                = "daily_backup_rule"
    target_vault_name        = aws_backup_vault.this.name
    schedule                 = var.daily_backup_plan
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window
    enable_continuous_backup = false

    recovery_point_tags = {
      Name = "${var.name}-backups"
    }

    lifecycle {
      cold_storage_after = var.daily_backup_plan_move_to_cold_storage
      delete_after       = var.daily_backup_plan_delete_after
    }
  }
}

resource "aws_backup_selection" "daily" {
  iam_role_arn = aws_iam_role.this.arn
  name         = "${var.name}-daily-backups"
  plan_id      = aws_backup_plan.daily.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "true"
  }
}

resource "aws_backup_plan" "weekly" {
  name = "${var.name}-weekly-backup-plan"

  rule {
    rule_name                = "weekly_backup_rule"
    target_vault_name        = aws_backup_vault.this.name
    schedule                 = var.weekly_backup_plan
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window
    enable_continuous_backup = false

    recovery_point_tags = {
      Name = "${var.name}-backups"
    }

    lifecycle {
      cold_storage_after = var.weekly_backup_plan_move_to_cold_storage
      delete_after       = var.weekly_backup_plan_delete_after
    }
  }
}

resource "aws_backup_selection" "weekly" {
  iam_role_arn = aws_iam_role.this.arn
  name         = "${var.name}-weekly-backups"
  plan_id      = aws_backup_plan.weekly.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "true"
  }
}

resource "aws_backup_plan" "monthly" {
  name = "${var.name}-monthly-backup-plan"

  rule {
    rule_name                = "monthly_backup_rule"
    target_vault_name        = aws_backup_vault.this.name
    schedule                 = var.monthly_backup_plan
    start_window             = var.backup_start_window
    completion_window        = var.backup_completion_window
    enable_continuous_backup = false

    recovery_point_tags = {
      Name = "${var.name}-backups"
    }

    lifecycle {
      cold_storage_after = var.monthly_backup_plan_move_to_cold_storage
      delete_after       = var.monthly_backup_plan_delete_after
    }
  }
}

resource "aws_backup_selection" "monthly" {
  iam_role_arn = aws_iam_role.this.arn
  name         = "${var.name}-monthly-backups"
  plan_id      = aws_backup_plan.monthly.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "backup"
    value = "true"
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-aws-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backups.json
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.this.name
}

# SNS Topic for technical alerts
resource "aws_kms_key" "sns" {
  description             = "KMS key for SNS topic encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.service_tags,
    {
      Name = "${var.name}-sns-key"
    }
  )
}

resource "aws_kms_alias" "sns" {
  name          = "alias/${var.name}-sns"
  target_key_id = aws_kms_key.sns.key_id
}

resource "aws_sns_topic" "technical_alerts_topic" {
  name              = "${var.name}-technical-alert"
  kms_master_key_id = aws_kms_key.sns.id

  tags = merge(
    var.service_tags,
    {
      Name = "${var.name}-technical-alert"
    }
  )
}

resource "aws_sns_topic_subscription" "technical_alerts_subscription" {
  count     = trimspace(var.sns_subscriber_email) != "" ? 1 : 0
  topic_arn = aws_sns_topic.technical_alerts_topic.arn
  protocol  = "email"
  endpoint  = var.sns_subscriber_email
}
