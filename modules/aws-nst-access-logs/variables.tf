variable "name" {
  type        = string
  description = "Prefix of the S3 bucket"
}

variable "alb_logs_prefix" {
  type        = string
  description = "S3 prefix for ALB logs"
  default     = ""
}

variable "service_tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
