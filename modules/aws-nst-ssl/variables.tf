
variable "service_tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "dns" {
  description = "DNS name"
  type        = string
}

variable "verification" {
  description = "Verification type"
  type        = string
  default     = "DNS"
}
