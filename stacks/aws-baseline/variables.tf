variable "name" {
  type        = string
  description = "Name prefix for resources"
  default     = ""
}

variable "environment" {
  type    = string
  default = ""
}

variable "monthly_budget_limit_amount" {
  type    = string
  default = ""
}

variable "budget_alerts_emails" {
  type        = list(string)
  sensitive   = true
  description = "Email addresses for 50% and 100% budget alerts"
  default     = []
}

variable "budget_alerts_escalations_emails" {
  type        = list(string)
  sensitive   = true
  description = "Email addresses for 150% budget escalation alerts"
  default     = []
}

