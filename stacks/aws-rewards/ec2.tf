module "ec2" {
  source = "../../modules/aws-nst-ec2"

  service_name = var.name
  ec2          = local.ec2_base
  service_tags = var.tags
}
