module "ec2" {
  source = "../../modules/aws-nst-ec2"

  service_name            = var.name
  ec2                     = local.ec2_base
  service_tags            = var.tags
  additional_policy_arns  = [aws_iam_policy.ansible_artifacts_read.arn]
  ansible_artifact_bucket = module.s3-buckets["${var.name}-ansible-artifacts"].bucket

  depends_on = [aws_iam_policy.ansible_artifacts_read]
}

module "app_secret" {
  source = "../../modules/aws-nst-secret-manager"

  name         = "rewards/app-secret"
  description  = "Application secret for the rewards service"
  service_tags = var.tags
}
