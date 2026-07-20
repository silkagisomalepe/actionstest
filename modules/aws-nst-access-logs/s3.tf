resource "aws_s3_bucket" "web_lb_logs" {
  bucket = var.name

  tags = merge(var.service_tags, {
    Name = var.name
  })
}

resource "aws_s3_bucket_versioning" "web_lb_logs" {
  bucket     = aws_s3_bucket.web_lb_logs.id
  depends_on = [aws_s3_bucket.web_lb_logs]

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web_lb_logs" {
  bucket     = aws_s3_bucket.web_lb_logs.id
  depends_on = [aws_s3_bucket.web_lb_logs]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "web_lb_logs" {
  bucket = aws_s3_bucket.web_lb_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "web_lb_logs" {
  bucket     = aws_s3_bucket.web_lb_logs.id
  depends_on = [aws_s3_bucket.web_lb_logs, aws_s3_bucket_ownership_controls.web_lb_logs]
  acl        = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "web_lb_logs" {
  bucket     = aws_s3_bucket.web_lb_logs.id
  depends_on = [aws_s3_bucket.web_lb_logs]

  rule {
    id = "Expire in 365 Days"
    expiration {
      days = 365
    }
    filter {
      prefix = ""
    }
    noncurrent_version_expiration {
      noncurrent_days = 365
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "web_s3_bucket_policy" {
  bucket = aws_s3_bucket.web_lb_logs.id
  policy = data.aws_iam_policy_document.alb_logs.json
}

resource "aws_s3_bucket_public_access_block" "web_lb_logs" {
  bucket                  = aws_s3_bucket.web_lb_logs.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
