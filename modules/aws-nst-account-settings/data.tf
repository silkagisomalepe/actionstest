data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_key" "ebs" {
  key_id = "alias/aws/ebs"
}

data "aws_kms_key" "backup" {
  key_id = "alias/aws/backup"
}

data "aws_iam_policy_document" "sns_policy" {

  statement {
    sid = "Allow_CloudWatch_for_CMK"
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [
      "*"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow_Publish_Alarms"
    actions = [
      "sns:Publish"
    ]
    resources = [
      "arn:aws:sns:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${var.name}-technical-alert"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudwatch:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:alarm:*", ]
    }
  }

  statement {
    sid       = "AllowSNSKMSAccess"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "backups" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}
