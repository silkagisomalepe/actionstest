
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms_waf" {
  statement {
    sid    = "EnableIAMUserPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowWAFLogDeliveryToUseTheKey"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "waf_s3_enforce_ssl" {
  statement {
    sid       = "DenyIfNotUsingSecureTransport"
    effect    = "Deny"
    resources = ["${aws_s3_bucket.waf.arn}/*"]
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
