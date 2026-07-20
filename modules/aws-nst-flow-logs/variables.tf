variable "name" {
  type        = string
  description = "Prefix of the flowlogs resources"
}

variable "service_tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "access_logs_bucket" {
  type        = string
  description = "Access logs bucket"
  default     = ""
}
