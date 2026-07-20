output "technical_alerts_topic" {
  description = "ARN of the SNS topic for technical alerts"
  value       = aws_sns_topic.technical_alerts_topic.arn
}