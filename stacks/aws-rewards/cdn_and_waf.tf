module "waf" {
  source       = "../../modules/aws-nst-waf"
  name         = "${var.name}-waf"
  scope        = "REGIONAL"
  service_tags = var.tags
}

resource "aws_wafv2_web_acl_association" "lb" {
  for_each = {
    private = module.alb-public.arn
  }
  resource_arn = each.value
  web_acl_arn  = module.waf.web_acl_arn
}
