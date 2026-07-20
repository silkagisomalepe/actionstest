variable "service_tags" {
  description = "Resource tags"
  type        = map(string)

  default = {}
}

variable "name" {
  description = "Name of the service"
  type        = string
}

variable "scope" {
  description = "Scope for CDN"
  type        = string
  default     = "REGIONAL"
}
