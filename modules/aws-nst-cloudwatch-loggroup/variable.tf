variable "create" {
  type        = bool
  description = "Whether to create the CloudWatch log group"
  default     = true
}

variable "name" {
  type        = string
  description = "Name of the CloudWatch log group"
  default     = null
}

variable "name_prefix" {
  type        = string
  description = "Prefix for the CloudWatch log group name"
  default     = null
}

variable "retention_in_days" {
  type        = number
  description = "Number of days to retain log events (null = never expire)"
  default     = null
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID for encrypting the log group"
  default     = null
}


