variable "is_enabled" {
  type        = bool
  default     = true
  description = "Whether the AWS Config recorder is enabled"
}

variable "config_name" {
  type        = string
  default     = ""
  description = "Client Name/Environment for use as a prefix"
}

variable "config_logs_prefix" {
  type        = string
  default     = ""
  description = "S3 key prefix for AWS Config logs"
}

variable "config_delivery_frequency" {
  type        = string
  default     = "TwentyFour_Hours"
  description = "Frequency for AWS Config to deliver snapshots (e.g. One_Hour, TwentyFour_Hours)"
}

variable "include_global_resource_types" {
  type        = bool
  default     = true
  description = "Whether to include global resource types in the recording group"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment environment"
}

variable "config_lifecycle_bucket" {
  type        = number
  default     = 365
  description = "S3 Bucket for Config Lifecycle Logs in days"
}

variable "access_logs_bucket" {
  type        = string
  description = "Access logs bucket"
  default     = ""
}
