variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
  default     = ""
}

variable "workload_name" {
  type        = string
  description = "Name used as a resource name prefix"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Deployment stage (e.g. dev, staging, prod)"
  default     = ""
}

variable "monthly_budget_limit_amount" {
  type        = string
  description = "Monthly spend threshold in USD that triggers budget alerts"
  default     = ""
}

variable "budget_alerts_emails" {
  type        = list(string)
  description = "Email addresses that receive budget threshold alerts (50% and 100%)"
  default     = ["billing@example.com"]
}

variable "budget_alerts_escalations_emails" {
  type        = list(string)
  description = "Email addresses that receive escalated budget alerts (150%)"
  default     = ["billing@example.com"]
}

variable "vpc_name" {
  type        = string
  description = "Name tag applied to the VPC"
  default     = ""
}

variable "cidr" {
  type        = string
  description = "Primary CIDR block for the VPC"
  default     = ""
}

variable "az_count" {
  type        = number
  description = "Availability zones to deploy subnets into"
  default     = 3
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create a NAT gateway for private subnet egress"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Whether to use a single NAT gateway across all AZs (cost optimisation)"
  default     = true
}

variable "enable_dns_hostname" {
  type        = bool
  description = "Whether to enable DNS hostnames in the VPC"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Whether to enable DNS resolution in the VPC"
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
