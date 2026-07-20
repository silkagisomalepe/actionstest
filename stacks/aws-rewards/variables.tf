variable "name" {
  type    = string
  default = ""
}

variable "access_logs_bucket" {
  type        = string
  description = "S3 bucket that receives ALB access and connection logs, and VPC flow logs"
  default     = ""
}

variable "vpc_name" {
  type    = string
  default = ""
}

variable "cidr" {
  type    = string
  default = ""
}

variable "az_count" {
  type    = number
  default = 3
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_dns_hostname" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "create_database_subnet_group" {
  type    = bool
  default = false
}

#pending dns-delegation
# variable "public_aliases" {
#   type    = list(string)
#   default = []
# }

variable "private_dns" {
  type    = string
  default = "local"
}

variable "public_dns" {
  type    = string
  default = ""
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
