locals {
  tags = merge(var.service_tags, {
    Environment = var.environment
  })
}

module "kms_key" {
  source                  = "../../modules/aws-nst-kms"
  description             = "cloudtrail-kms-key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  alias                   = "alias/${var.name}-key"
  policy                  = data.aws_iam_policy_document.kms.json
}


resource "aws_s3_bucket" "aws_cloudtrail" {
  bucket = var.name

  tags = merge(local.tags, {
    Name = var.name
  })
}

resource "aws_s3_bucket_versioning" "aws_cloudtrail" {
  bucket     = aws_s3_bucket.aws_cloudtrail.id
  depends_on = [aws_s3_bucket.aws_cloudtrail]

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aws_cloudtrail" {
  bucket     = aws_s3_bucket.aws_cloudtrail.id
  depends_on = [aws_s3_bucket.aws_cloudtrail]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = module.kms_key.key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_ownership_controls" "aws_cloudtrail" {
  bucket = aws_s3_bucket.aws_cloudtrail.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "aws_cloudtrail" {
  bucket     = aws_s3_bucket.aws_cloudtrail.id
  depends_on = [aws_s3_bucket.aws_cloudtrail, aws_s3_bucket_ownership_controls.aws_cloudtrail]
  acl        = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "aws_cloudtrail" {
  bucket     = aws_s3_bucket.aws_cloudtrail.id
  depends_on = [aws_s3_bucket.aws_cloudtrail]

  rule {
    id = "Expire in ${var.cloudtrail_lifecycle_bucket} Days"
    expiration {
      days = var.cloudtrail_lifecycle_bucket
    }
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = var.cloudtrail_lifecycle_bucket
    }

    status = "Enabled"
  }

}


resource "aws_s3_bucket_policy" "aws_cloudtrail" {
  bucket     = aws_s3_bucket.aws_cloudtrail.id
  depends_on = [aws_s3_bucket.aws_cloudtrail]
  policy     = data.aws_iam_policy_document.s3_cloudtrail.json
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_s3" {
  bucket                  = aws_s3_bucket.aws_cloudtrail.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "aws_cloudtrail" {
  bucket = aws_s3_bucket.aws_cloudtrail.bucket

  target_bucket = var.access_logs_bucket
  target_prefix = ""
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

resource "aws_iam_role" "cloudwatch_role" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json

  tags = merge(local.tags, {
    Name = "${var.name}-role"
  })
}

resource "aws_iam_policy" "cloudtrail_role_policy" {
  name        = "${var.name}-policy"
  description = "Policy used for Cloudtrail"
  policy      = data.aws_iam_policy_document.cloudtrail_policy.json

  tags = merge(local.tags, {
    Name = "${var.name}-policy"
  })
}

resource "aws_iam_role_policy_attachment" "cloudtrail_role_policy" {
  policy_arn = aws_iam_policy.cloudtrail_role_policy.arn
  role       = aws_iam_role.cloudwatch_role.name
}

module "log_group" {
  source            = "../aws-nst-cloudwatch-loggroup"
  name              = var.name
  retention_in_days = 365
  kms_key_id        = module.kms_key.key_arn
}

resource "aws_cloudtrail" "aws_cloudtrail" {
  name                          = var.name
  enable_logging                = var.enable_logging
  s3_bucket_name                = aws_s3_bucket.aws_cloudtrail.id
  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_role_arn     = aws_iam_role.cloudwatch_role.arn
  cloud_watch_logs_group_arn    = format("%s:*", module.log_group.cloudwatch_log_group_arn)
  kms_key_id                    = module.kms_key.key_arn
  s3_key_prefix                 = "cloudtrail"
  tags = merge(local.tags, {
    Name = var.name
  })

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda"]
    }
  }

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
}
