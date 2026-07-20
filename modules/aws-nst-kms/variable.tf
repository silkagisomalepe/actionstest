variable "deletion_window_in_days" {
  type        = number
  description = "Number of days before the KMS key is deleted after destruction"
  default     = 7
}

variable "description" {
  type        = string
  description = "Description of the KMS key"
  default     = "Parameter Store KMS master key"
}

variable "is_enabled" {
  type        = bool
  description = "Whether the KMS key is enabled"
  default     = true
}

variable "enabled" {
  type        = bool
  description = "Whether the KMS key resource is created"
  default     = true
}

variable "key_usage" {
  type        = string
  description = "Intended use of the KMS key (e.g. ENCRYPT_DECRYPT)"
  default     = "ENCRYPT_DECRYPT"
}

variable "alias" {
  type        = string
  description = "Alias name for the KMS key (without alias/ prefix)"
  default     = ""
}

variable "policy" {
  type        = string
  description = "Key policy JSON document"
  default     = ""
}

variable "customer_master_key_spec" {
  type        = string
  description = "KMS key spec (e.g. SYMMETRIC_DEFAULT, RSA_2048)"
  default     = "SYMMETRIC_DEFAULT"
}

variable "enable_key_rotation" {
  type        = bool
  description = "Whether automatic key rotation is enabled"
  default     = true
}

variable "service_tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
