output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = element(concat(aws_cloudwatch_log_group.loggroup[*].name, [""]), 0)
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = element(concat(aws_cloudwatch_log_group.loggroup[*].arn, [""]), 0)
}
