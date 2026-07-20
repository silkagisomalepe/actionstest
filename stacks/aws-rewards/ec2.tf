module "ec2" {
  source = "../../modules/aws-nst-ec2"

  service_name           = var.name
  ec2                    = local.ec2_base
  service_tags           = var.tags
  additional_policy_arns = [aws_iam_policy.ansible_artifacts_read.arn]

  depends_on = [aws_iam_policy.ansible_artifacts_read]
}
