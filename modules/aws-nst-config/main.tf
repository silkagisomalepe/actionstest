resource "aws_iam_role" "config_role" {
  name               = "${var.config_name}-role"
  assume_role_policy = data.aws_iam_policy_document.aws_config_role_policy.json

  tags = merge(var.service_tags, {
    Name = "${var.config_name}-role"
  })
}

resource "aws_iam_role_policy_attachment" "managed_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_policy" "aws_config_policy" {
  name   = "${var.config_name}-policy"
  policy = data.aws_iam_policy_document.aws_config_policy.json

  tags = merge(var.service_tags, {
    Name = "${var.config_name}-policy"
  })
}

resource "aws_iam_role_policy_attachment" "aws_config_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = aws_iam_policy.aws_config_policy.arn
}

resource "aws_config_configuration_recorder_status" "recorder" {
  name       = var.config_name
  is_enabled = var.is_enabled
  depends_on = [aws_config_delivery_channel.recorder]
}

resource "aws_config_delivery_channel" "recorder" {
  name           = var.config_name
  s3_bucket_name = aws_s3_bucket.aws_config.bucket
  s3_key_prefix  = var.config_logs_prefix

  snapshot_delivery_properties {
    delivery_frequency = var.config_delivery_frequency
  }
  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_configuration_recorder" "recorder" {
  name     = var.config_name
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}


resource "aws_config_conformance_pack" "operational_best_practices_for_aws_identity_and_access_management" {
  name          = "Operational-Best-Practices-for-AWS-Identity-and-Access-Management"
  template_body = file("${path.module}/conformance-packs/Operational-Best-Practices-for-AWS-Identity-and-Access-Management.yaml")

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_conformance_pack" "operational_best_practices_for_amazon_s3" {
  name          = "Operational-Best-Practices-for-Amazon-S3"
  template_body = file("${path.module}/conformance-packs/Operational-Best-Practices-for-Amazon-S3.yaml")

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_kms_key" "config" {
  description             = "config-logs-key"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.config_kms.json

  tags = merge(var.service_tags, {
    Name = "${var.config_name}-key"
  })
}

resource "aws_kms_alias" "config" {
  name          = "alias/${var.config_name}-key"
  target_key_id = aws_kms_key.config.id
}

resource "aws_s3_bucket" "aws_config" {
  bucket = "${var.config_name}-logs"

  tags = merge(var.service_tags, {
    Name = "${var.config_name}-logs"
  })
}

resource "aws_s3_bucket_policy" "aws_config" {
  bucket     = aws_s3_bucket.aws_config.id
  depends_on = [aws_s3_bucket.aws_config]
  policy     = data.aws_iam_policy_document.s3_config.json
}

resource "aws_s3_bucket_versioning" "aws_config" {
  bucket     = aws_s3_bucket.aws_config.id
  depends_on = [aws_s3_bucket.aws_config]

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_config" {
  bucket     = aws_s3_bucket.aws_config.id
  depends_on = [aws_s3_bucket.aws_config]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.config.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_ownership_controls" "aws_config" {
  bucket = aws_s3_bucket.aws_config.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_acl" "aws_config" {
  bucket     = aws_s3_bucket.aws_config.id
  depends_on = [aws_s3_bucket.aws_config, aws_s3_bucket_ownership_controls.aws_config]
  acl        = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "aws_config" {
  bucket     = aws_s3_bucket.aws_config.id
  depends_on = [aws_s3_bucket.aws_config]

  rule {
    id = "Expire in ${var.config_lifecycle_bucket} Days"
    expiration {
      days = var.config_lifecycle_bucket
    }
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = var.config_lifecycle_bucket
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "config_bucket_s3" {
  bucket                  = aws_s3_bucket.aws_config.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "aws_config" {
  bucket = aws_s3_bucket.aws_config.bucket

  target_bucket = var.access_logs_bucket
  target_prefix = ""
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

resource "aws_config_conformance_pack" "security_services" {
  name          = "OperationalBestPracticesforSecurityServices"
  template_body = file("${path.module}/conformance-packs/Operational-Best-Practices-for-Security-Services.yaml")
}
