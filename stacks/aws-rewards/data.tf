data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
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
