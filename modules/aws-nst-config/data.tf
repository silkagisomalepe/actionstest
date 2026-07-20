data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "config_kms" {
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
    sid    = "AllowConfigAccess"
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
      identifiers = ["config.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_config" {
  statement {
    sid       = "AWSConfigAclCheck"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.config_name}-logs"]
    actions   = ["s3:GetBucketAcl"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSConfigWrite"
    effect    = "Allow"
    resources = ["arn:aws:s3:::${var.config_name}-logs/config/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }

  statement {
    sid       = "DenyIfNotUsingSecureTransport"
    effect    = "Deny"
    resources = ["arn:aws:s3:::${var.config_name}-logs/*"]
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

data "aws_iam_policy_document" "aws_config_policy" {

  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.aws_config.bucket}"
    ]
  }

  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.aws_config.bucket}"
    ]
  }

  statement {
    sid     = "AWSConfigBucketDelivery"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      format("arn:%s:s3:::%s%s%s/AWSLogs/%s/Config/*",
        data.aws_partition.current.partition,
        aws_s3_bucket.aws_config.bucket,
        var.config_logs_prefix == "" ? "" : "/",
        var.config_logs_prefix,
        data.aws_caller_identity.current.account_id
      )
    ]

    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

data "aws_iam_policy_document" "aws_config_role_policy" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    effect = "Allow"
  }
}