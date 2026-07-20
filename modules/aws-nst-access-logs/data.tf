data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "current" {}

data "aws_iam_policy_document" "alb_logs" {
  statement {
    sid       = "DenyIfNotUsingSecureTransport"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.web_lb_logs.arn}/*"]
    actions   = ["*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
  statement {
    sid       = "logsAcl1"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.web_lb_logs.bucket}"]
    actions   = ["s3:*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "logsAcl2"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.web_lb_logs.bucket}/*"]
    actions   = ["s3:*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "logsAcl3"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.web_lb_logs.bucket}/${var.alb_logs_prefix}/AWSLogs/*"]
    actions   = ["s3:*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "logsAcl4"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket.web_lb_logs.bucket}/${var.alb_logs_prefix}/AWSLogs/*"]
    actions   = ["s3:*"]

    principals {
      type = "AWS"

      identifiers = [
        data.aws_caller_identity.current.account_id,
        data.aws_elb_service_account.current.arn,
      ]
    }
  }

  statement {
    sid       = "AllowALBLogDeliveryPutObject"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.web_lb_logs.bucket}/${var.alb_logs_prefix}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid       = "AllowALBLogDeliveryGetBucketAcl"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.web_lb_logs.arn]

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
