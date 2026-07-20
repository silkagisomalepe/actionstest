variable "name" {
  type        = string
  description = "Prefix for AWS resources"
  default     = ""
}

variable "budget_alerts_emails" {
  sensitive   = true
  type        = list(string)
  description = "Email addresses for 50% and 100% budget alerts (actual and forecasted)"
  default     = []
}

variable "budget_alerts_escalations_emails" {
  sensitive   = true
  type        = list(string)
  description = "Email addresses for 150% budget escalation alerts (actual and forecasted)"
  default     = []
}

# Budgets
variable "limit_amount" {
  type        = number
  description = "Budget limit amount in USD"
  default     = 0
}

# IAM

variable "hard_expiry" {
  type        = bool
  description = "Whether to prevent IAM users from resetting an expired password"
  default     = false
}

variable "require_numbers" {
  type        = bool
  description = "Whether IAM user passwords must contain at least one numeric character"
  default     = true
}

variable "require_symbols" {
  type        = bool
  description = "Whether IAM user passwords must contain at least one symbol character"
  default     = true
}

variable "max_password_age" {
  type        = number
  description = "Number of days before an IAM user password expires"
  default     = 90
}

variable "minimum_password_length" {
  type        = number
  description = "Minimum number of characters allowed in an IAM user password"
  default     = 16
}

variable "password_reuse_prevention" {
  type        = number
  description = "Number of previous passwords that IAM users are prevented from reusing"
  default     = 24
}

variable "require_lowercase_characters" {
  type        = bool
  description = "Whether IAM user passwords must contain at least one lowercase character"
  default     = true
}

variable "require_uppercase_characters" {
  type        = bool
  description = "Whether IAM user passwords must contain at least one uppercase character"
  default     = true
}

variable "allow_users_to_change_password" {
  type        = bool
  description = "Whether IAM users are allowed to change their own password"
  default     = true
}

# Budgets

variable "budget_name" {
  type        = string
  description = "Budget name"
  default     = "budget"
}
variable "budget_type" {
  type        = string
  description = "Budget type"
  default     = "COST"
}
variable "limit_unit" {
  type        = string
  description = "Budget limit unit"
  default     = "USD"
}
variable "time_unit" {
  type        = string
  description = "Budget time unit"
  default     = "MONTHLY"
}
variable "include_credit" {
  type        = bool
  description = "Budget include credit"
  default     = false
}
variable "include_refund" {
  type        = bool
  description = "Budget include refund"
  default     = false
}
variable "include_discount" {
  type        = bool
  description = "Budget include discount"
  default     = false
}
variable "include_other_subscription" {
  type        = bool
  description = "Budget include other subscription"
  default     = true
}
variable "include_recurring" {
  type        = bool
  description = "Budget include recurring"
  default     = true
}
variable "include_subscription" {
  type        = bool
  description = "Budget include subscription"
  default     = true
}
variable "include_support" {
  type        = bool
  description = "Budget include support"
  default     = true
}
variable "include_tax" {
  type        = bool
  description = "Budget include tax"
  default     = true
}
variable "include_upfront" {
  type        = bool
  description = "Budget include upfront"
  default     = true
}
variable "use_blended" {
  default     = true
  type        = bool
  description = "Budget use blended"
}

# Technical alerts
variable "sns_subscriber_email" {
  sensitive   = true
  type        = string
  description = "Email address for SNS subscription"
  default     = ""
}

# Backup Plans

# Daily
variable "daily_backup_plan" {
  type        = string
  description = "Cron schedule for daily backup plan"
  default     = "cron(0 1 * * ? *)"
}

variable "daily_backup_plan_delete_after" {
  type        = number
  description = "Days after which daily backups are deleted"
  default     = 14
}

variable "daily_backup_plan_move_to_cold_storage" {
  type        = number
  description = "Days after which daily backups are moved to cold storage (0 = disabled)"
  default     = 0
}

# Weekly
variable "weekly_backup_plan" {
  type        = string
  description = "Cron schedule for weekly backup plan"
  default     = "cron(0 2 ? * 6 *)"
}

variable "weekly_backup_plan_delete_after" {
  type        = number
  description = "Days after which weekly backups are deleted"
  default     = 120
}

variable "weekly_backup_plan_move_to_cold_storage" {
  type        = number
  description = "Days after which weekly backups are moved to cold storage (0 = disabled)"
  default     = 0
}

# Monthly
variable "monthly_backup_plan" {
  type        = string
  description = "Cron schedule for monthly backup plan"
  default     = "cron(0 3 1 * ? *)"
}

variable "monthly_backup_plan_delete_after" {
  type        = number
  description = "Days after which monthly backups are deleted"
  default     = 420
}

variable "monthly_backup_plan_move_to_cold_storage" {
  type        = number
  description = "Days after which monthly backups are moved to cold storage (0 = disabled)"
  default     = 0
}

variable "backup_start_window" {
  type        = number
  description = "Minutes after a backup job is scheduled before it must start, or it is cancelled"
  default     = 60
}

variable "backup_completion_window" {
  type        = number
  description = "Minutes after a backup job is successfully started before it must complete, or it is cancelled"
  default     = 120
}

variable "service_tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "delete_default_vpc" {
  type        = bool
  description = "Whether to delete the default VPC in the current region"
  default     = false
}
