locals {
  tags = merge(var.service_tags, {
    Environment = var.environment
  })
}

resource "aws_guardduty_detector" "detector" {
  enable = true
}

resource "aws_guardduty_detector_feature" "s3_data_events" {
  detector_id = aws_guardduty_detector.detector.id
  name        = "S3_DATA_EVENTS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "eks_audit_logs" {
  detector_id = aws_guardduty_detector.detector.id
  name        = "EKS_AUDIT_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "ebs_malware_protection" {
  detector_id = aws_guardduty_detector.detector.id
  name        = "EBS_MALWARE_PROTECTION"
  status      = "ENABLED"
}

resource "aws_guardduty_detector_feature" "runtime_monitoring" {
  detector_id = aws_guardduty_detector.detector.id
  name        = "RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "DISABLED"
  }

  additional_configuration {
    name   = "ECS_FARGATE_AGENT_MANAGEMENT"
    status = "ENABLED"
  }

  additional_configuration {
    name   = "EC2_AGENT_MANAGEMENT"
    status = "DISABLED"
  }
}

resource "aws_guardduty_detector_feature" "lambda_protection" {
  detector_id = aws_guardduty_detector.detector.id
  name        = "LAMBDA_NETWORK_LOGS"
  status      = "ENABLED"
}

resource "aws_guardduty_publishing_destination" "guard_duty_logs" {
  detector_id     = aws_guardduty_detector.detector.id
  destination_arn = aws_s3_bucket.guard_duty_s3_bucket.arn
  kms_key_arn     = aws_kms_key.guard_duty_key.arn

  depends_on = [
    aws_s3_bucket_policy.guard_duty_bucket_policy,
  ]
}

resource "aws_s3_bucket" "guard_duty_s3_bucket" {
  bucket = "${var.workload_name}-${var.environment}-guardduty-logs"
  tags = merge(local.tags, {
    Name = "${var.workload_name}-${var.environment}-guardduty-logs"
  })
}

resource "aws_s3_bucket_versioning" "guard_duty_s3_bucket" {
  bucket     = aws_s3_bucket.guard_duty_s3_bucket.id
  depends_on = [aws_s3_bucket.guard_duty_s3_bucket]

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "guard_duty_s3_bucket" {
  bucket     = aws_s3_bucket.guard_duty_s3_bucket.id
  depends_on = [aws_s3_bucket.guard_duty_s3_bucket]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.guard_duty_key.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_ownership_controls" "guard_duty_s3_bucket" {
  bucket = aws_s3_bucket.guard_duty_s3_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "guard_duty_s3_bucket" {
  bucket     = aws_s3_bucket.guard_duty_s3_bucket.id
  depends_on = [aws_s3_bucket.guard_duty_s3_bucket, aws_s3_bucket_ownership_controls.guard_duty_s3_bucket]
  acl        = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "guard_duty_s3_bucket" {
  bucket     = aws_s3_bucket.guard_duty_s3_bucket.id
  depends_on = [aws_s3_bucket.guard_duty_s3_bucket]

  rule {
    id = "Expire in ${var.guardduty_lifecycle_days} Days"
    expiration {
      days = var.guardduty_lifecycle_days
    }
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = var.guardduty_lifecycle_days
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "guard_duty_bucket_policy" {
  bucket = aws_s3_bucket.guard_duty_s3_bucket.id
  policy = data.aws_iam_policy_document.guarduty_s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_alarm_bucket_s3" {
  bucket                  = aws_s3_bucket.guard_duty_s3_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_kms_alias" "guard_duty_key_alias" {
  name          = "alias/${var.workload_name}-${var.environment}-guardduty-key"
  target_key_id = aws_kms_key.guard_duty_key.id
}

resource "aws_kms_key" "guard_duty_key" {
  description             = "${var.workload_name}-${var.environment}-guardduty-key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_guard_duty_policy.json
}

resource "aws_s3_bucket_logging" "aws_cloudtrail" {
  bucket = aws_s3_bucket.guard_duty_s3_bucket.bucket

  target_bucket = var.access_logs_bucket
  target_prefix = ""
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}
