output "cloudtrail_id" {
  description = "ID of the CloudTrail trail"
  value       = aws_cloudtrail.aws_cloudtrail.id
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.aws_cloudtrail.arn
}

output "cloudtrail_home_region" {
  description = "Home region of the CloudTrail trail"
  value       = aws_cloudtrail.aws_cloudtrail.home_region
}

output "cloudtrail_log_group_name" {
  description = "Name of the CloudWatch log group for CloudTrail"
  value       = module.log_group.cloudwatch_log_group_name
}