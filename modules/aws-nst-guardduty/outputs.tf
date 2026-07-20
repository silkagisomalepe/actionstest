output "guardduty_detector_id" {
  description = "ARN of the GuardDuty detector"
  value       = aws_guardduty_detector.detector.arn
}

output "guardduty_s3_bucket_arn" {
  description = "ARN of the S3 bucket for GuardDuty findings"
  value       = aws_s3_bucket.guard_duty_s3_bucket.arn
}