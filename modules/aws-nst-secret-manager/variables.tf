variable "name" {
  description = "Name of the secret to be created."
  type        = string
}

variable "secret_string" {
  description = "Optional fixed secret string. If not provided, one will be generated."
  type        = string
  default     = null
}

variable "description" {
  description = "Optional description of the secret."
  type        = string
  default     = null
}

variable "rotation_lambda_arn" {
  description = "ARN of the Lambda function that rotates this secret. Rotation is disabled when null."
  type        = string
  default     = null
}

variable "rotation_days" {
  description = "Number of days between automatic secret rotations."
  type        = number
  default     = 30
}

variable "service_tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
