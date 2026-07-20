data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "current" {}

data "aws_iam_policy_document" "access_logs_kms" {
  statement {
    sid       = "EnableRootAccess"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowS3Access"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }

  statement {
    sid    = "AllowDeliveryLogsAccess"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

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
}
