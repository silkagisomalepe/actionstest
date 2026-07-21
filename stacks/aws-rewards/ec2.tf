module "ec2" {
  source = "../../modules/aws-nst-ec2"

  service_name            = var.name
  ec2                     = local.ec2_base
  service_tags            = var.tags
  additional_policy_arns  = [aws_iam_policy.ansible_artifacts_read.arn, aws_iam_policy.app_secret_read.arn]
  ansible_artifact_bucket = module.s3-buckets["${var.name}-ansible-artifacts"].bucket

  depends_on = [aws_iam_policy.ansible_artifacts_read, aws_iam_policy.app_secret_read]
}

module "app_secret" {
  source = "../../modules/aws-nst-secret-manager"

  name         = "APP_SECRET"
  description  = "Application secret for the rewards service"
  service_tags = var.tags
}

data "aws_iam_policy_document" "app_secret_read" {
  statement {
    sid       = "ReadAppSecret"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [module.app_secret.secret_arn]
  }

  statement {
    sid       = "DecryptAppSecret"
    actions   = ["kms:Decrypt"]
    resources = [module.app_secret.kms_key_arn]
  }
}

resource "aws_iam_policy" "app_secret_read" {
  name        = "${var.name}-app-secret-read"
  description = "Allows EC2 instances to read and decrypt the APP_SECRET secret"
  policy      = data.aws_iam_policy_document.app_secret_read.json
  tags        = var.tags
}
