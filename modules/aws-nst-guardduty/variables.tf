variable "workload_name" {
  type        = string
  default     = ""
  description = "Client Name for use as a prefix"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Envrionment environment"
}

variable "guardduty_lifecycle_days" {
  type        = number
  default     = 365
  description = "S3 Bucket for GuardDuty Lifecycle Logs"
}

variable "access_logs_bucket" {
  type        = string
  description = "Access logs bucket"
  default     = ""
}

variable "service_tags" {
  type        = map(string)
  description = "Additional tags to merge onto all resources"
  default     = {}
}
