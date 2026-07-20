variable "name" {
  type        = string
  description = "Name prefix for CloudTrail resources"
  default     = ""
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment environment"
}

variable "enable_logging" {
  type        = bool
  description = "Whether CloudTrail logging is enabled"
  default     = true
}

variable "enable_log_file_validation" {
  type        = bool
  description = "Whether CloudTrail log file integrity validation is enabled"
  default     = true
}

variable "is_multi_region_trail" {
  type        = bool
  description = "Whether the trail is a multi-region trail"
  default     = true
}

variable "include_global_service_events" {
  type        = bool
  description = "Whether to include global service events such as IAM"
  default     = true
}

variable "cloudtrail_lifecycle_bucket" {
  type        = number
  description = "CloudTrail lifecycle duration in days"
  default     = 90
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
