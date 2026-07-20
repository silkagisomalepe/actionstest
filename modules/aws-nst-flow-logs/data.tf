
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "flow_logs_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    resources = [
      "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.name}",
      "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${var.name}:*",
    ]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
  }
}

data "aws_iam_policy_document" "flowlog_kms" {
  statement {
    sid    = "EnableIAMPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

data "aws_iam_policy_document" "s3_flowlogs" {
  statement {
    sid       = "DenyIfNotUsingSecureTransport"
    effect    = "Deny"
    resources = ["arn:aws:s3:::${var.name}/*"]
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
