output "bucket" {
  description = "The bucket name"
  value       = aws_s3_bucket.bucket.bucket
}

output "bucket_id" {
  description = "The bucket ID (name)"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  description = "The bucket ARN"
  value       = aws_s3_bucket.bucket.arn
}

output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.bucket.arn
}
