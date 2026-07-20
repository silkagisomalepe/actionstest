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

resource "aws_iam_policy" "ansible_artifacts_read" {
  name        = "${var.name}-ansible-artifacts-read"
  description = "${var.name}-ansible-artifacts-read"
  policy      = data.aws_iam_policy_document.ansible_artifacts_read.json
  tags        = var.tags
}
