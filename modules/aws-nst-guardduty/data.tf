data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "guarduty_s3_policy" {
  statement {
    sid       = "Deny non-HTTPS access"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.guard_duty_s3_bucket.arn}/*"]
    actions   = ["s3:*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "Service"
      identifiers = ["guardduty.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  statement {
    sid       = "Deny incorrect encryption header"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.guard_duty_s3_bucket.arn}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [aws_kms_key.guard_duty_key.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["guardduty.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  statement {
    sid       = "Deny unencrypted object uploads"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.guard_duty_s3_bucket.arn}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }

    principals {
      type        = "Service"
      identifiers = ["guardduty.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  statement {
    sid       = "Allow PutObject"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.guard_duty_s3_bucket.arn}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_guardduty_detector.detector.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["guardduty.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  statement {
    sid       = "Allow GetBucketLocation"
    effect    = "Allow"
    resources = [aws_s3_bucket.guard_duty_s3_bucket.arn]
    actions   = ["s3:GetBucketLocation"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_guardduty_detector.detector.arn]
    }

    principals {
      type        = "Service"
      identifiers = ["guardduty.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  statement {
    sid       = "DenyIfNotUsingSecureTransport"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.guard_duty_s3_bucket.arn}/*"]
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
}

data "aws_iam_policy_document" "kms_guard_duty_policy" {

  statement {
    sid = "Allow GuardDuty to encrypt findings"
    actions = [
      "kms:GenerateDataKey"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow admin users to modify/delete key"
    actions = [
      "kms:*"
    ]

    resources = [
      "arn:aws:kms:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:key/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}
