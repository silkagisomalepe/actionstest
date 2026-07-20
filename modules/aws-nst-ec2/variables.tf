variable "ec2" {
  description = "List of EC2 instance configurations"
  type = list(object({
    name                   = string
    type                   = string
    ami                    = string
    subnet_id              = string
    vpc_zone_subnet_ids    = list(string)
    volume_size            = number
    security_group_ids     = list(string)
    target_group_arns      = list(string)
    user_data              = optional(string, "")
    alerts_topic_arn       = string
    enable_ssm             = optional(bool, true)
    enable_autoscaling     = optional(bool, false)
    desired_capacity       = optional(number, 1)
    min_size               = optional(number, 1)
    max_size               = optional(number, 1)
    target_cpu_utilization = optional(number, 70)
  }))
}

variable "service_name" {
  description = "Service name prefix for shared resources"
  type        = string
}

variable "service_tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
