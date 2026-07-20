resource "awsutils_default_vpc_deletion" "current" {
  count = var.delete_default_vpc ? 1 : 0
}

resource "aws_ebs_default_kms_key" "current" {
  key_arn = data.aws_kms_key.ebs.arn
}

resource "aws_ebs_encryption_by_default" "current" {
  enabled = true
}
