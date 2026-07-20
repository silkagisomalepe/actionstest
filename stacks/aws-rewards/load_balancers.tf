module "alb-public" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.10.0"

  name    = "${var.name}-alb-private"
  vpc_id  = module.vpc.vpc_id
  subnets = slice(module.vpc.public_subnets, 0, min(3, length(module.vpc.public_subnets)))

  internal                   = true
  enable_deletion_protection = false #set to true if not demo
  preserve_host_header       = true
  create_security_group      = false
  security_groups            = [module.alb-public-sg.security_group_id]

  listeners = merge(
    {
      http = {
        port     = 80
        protocol = "HTTP"
        redirect = {
          port        = "443"
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        }
      }
    },
    #needs ssl cert verification
    {
      https = {
        port            = 443
        protocol        = "HTTPS"
        ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
        certificate_arn = one(module.acm-alb[*].ssl_cert_arn)
        action-type     = "fixed-response"
        fixed_response = {
          content_type = "text/plain"
          message_body = "default response"
          status_code  = "200"
        }
        rules = [
          for index, service in [for s in local.ec2_base : s if s.attach_to_public_facing_lb == true] : {
            priority = index + 2
            actions = [{
              type             = "forward"
              target_group_arn = module.ecs-service.lb_target_group_arn[service.name]
            }]
            conditions = [{
              host_header = {
                values = ["${replace(service.name, "${var.name}-", "")}.${var.public_dns}"]
              }
            }]
          }
        ]
      }
    }
  )

  access_logs = {
    bucket  = var.access_logs_bucket
    prefix  = "alb"
    enabled = true
  }

  connection_logs = {
    bucket  = var.access_logs_bucket
    prefix  = "alb"
    enabled = true
  }
}
