
resource "aws_kms_key" "flowlog" {
  description             = "flow-logs-kms-key"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.flowlog_kms.json
}

resource "aws_kms_alias" "flowlog" {
  name          = "alias/${var.name}-key"
  target_key_id = aws_kms_key.flowlog.id
}

resource "aws_cloudwatch_log_group" "flowlog_loggroup" {
  name              = var.name
  retention_in_days = 365
  kms_key_id        = aws_kms_key.flowlog.arn

  tags = merge(var.service_tags, {
    Name = var.name
  })
}


resource "aws_iam_role" "flowlog_role_cloudwatch" {
  name               = "${var.name}-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.flow_logs.json
}

resource "aws_flow_log" "flowlog_cloudwatch" {
  iam_role_arn    = aws_iam_role.flowlog_role_cloudwatch.arn
  log_destination = aws_cloudwatch_log_group.flowlog_loggroup.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
  tags = merge(var.service_tags, {
    Name = "${var.name}-cloudwatch"
  })
}

resource "aws_iam_role_policy" "flowlog_policy_cloudwatch" {
  name   = "${var.name}-policy"
  role   = aws_iam_role.flowlog_role_cloudwatch.id
  policy = data.aws_iam_policy_document.flow_logs_policy.json
}

resource "aws_flow_log" "flowlog_s3" {
  log_destination      = aws_s3_bucket.flowlog_bucket_s3.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  tags = merge(var.service_tags, {
    Name = "${var.name}-s3"
  })
}

resource "aws_s3_bucket" "flowlog_bucket_s3" {
  bucket = var.name
  tags = merge(var.service_tags, {
    Name = var.name
    }
  )
}

resource "aws_s3_bucket_versioning" "flowlog_bucket_s3" {
  bucket     = aws_s3_bucket.flowlog_bucket_s3.id
  depends_on = [aws_s3_bucket.flowlog_bucket_s3]

  versioning_configuration {
    status = "Enabled"
  }
}

#tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "flowlog_bucket_s3" {
  bucket     = aws_s3_bucket.flowlog_bucket_s3.id
  depends_on = [aws_s3_bucket.flowlog_bucket_s3]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }

}

resource "aws_s3_bucket_lifecycle_configuration" "flowlog_bucket_s3" {
  bucket     = aws_s3_bucket.flowlog_bucket_s3.id
  depends_on = [aws_s3_bucket.flowlog_bucket_s3]

  rule {
    id = "Expire in 365 Days"
    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
    filter {
      prefix = ""
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "s3_flowlogs" {
  bucket     = aws_s3_bucket.flowlog_bucket_s3.id
  policy     = data.aws_iam_policy_document.s3_flowlogs.json
  depends_on = [aws_s3_bucket.flowlog_bucket_s3]
}

resource "aws_s3_bucket_logging" "aws_cloudtrail" {
  bucket = aws_s3_bucket.flowlog_bucket_s3.bucket

  target_bucket = var.access_logs_bucket
  target_prefix = ""
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "flowlog_bucket_s3" {
  bucket                  = aws_s3_bucket.flowlog_bucket_s3.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
