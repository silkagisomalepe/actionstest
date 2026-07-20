locals {
  bucket_names = [
    "${var.name}-ansible-artifacts",
  ]
}

module "s3-buckets" {
  source = "../../modules/aws-nst-s3"

  for_each = toset(local.bucket_names)
  name     = each.value
  tags     = var.tags
}

data "aws_iam_policy_document" "ansible_artifacts_read" {
  statement {
    sid       = "ReadAnsibleArtifacts"
    actions   = ["s3:GetObject"]
    resources = ["${module.s3-buckets["${var.name}-ansible-artifacts"].bucket_arn}/*"]
  }

  statement {
    sid       = "ListAnsibleArtifactsBucket"
    actions   = ["s3:ListBucket"]
    resources = [module.s3-buckets["${var.name}-ansible-artifacts"].bucket_arn]
  }

  statement {
    sid       = "DecryptAnsibleArtifacts"
    actions   = ["kms:Decrypt"]
    resources = [module.s3-buckets["${var.name}-ansible-artifacts"].kms_key_arn]
  }
}

resource "aws_iam_policy" "ansible_artifacts_read" {
  name        = "${var.name}-ansible-artifacts-read"
  description = "Allows EC2 instances to read and decrypt the Ansible deployment artifact bucket via SSM"
  policy      = data.aws_iam_policy_document.ansible_artifacts_read.json
  tags        = var.tags
}
