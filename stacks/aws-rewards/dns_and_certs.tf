module "acm-alb" {
  count        = var.public_dns != "" ? 1 : 0
  source       = "../../modules/aws-nst-ssl"
  dns          = var.public_dns
  service_tags = var.tags
}

module "hostedzone-private" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 4.1.0"
  zones = {
    (var.private_dns) = {
      comment = var.private_dns
      private = true
      vpc = [
        { vpc_id = module.vpc.vpc_id }
      ]
      tags = merge(var.tags, {
        Name = var.private_dns
      })
    }
  }
}

