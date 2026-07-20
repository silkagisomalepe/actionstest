#trivy:ignore:AWS-0054
module "alb-public" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.10.0"

  name    = "${var.name}-alb-public"
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
        forward = {
          target_group_key = "rewards"
        }
        # redirect = {
        #   port        = "443"
        #   protocol    = "HTTPS"
        #   status_code = "HTTP_301"
        # }
      }
    },
    #needs ssl cert verification
    # {
    #   https = {
    #     port            = 443
    #     protocol        = "HTTPS"
    #     ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    #     certificate_arn = one(module.acm-alb[*].ssl_cert_arn)
    #     forward = {
    #       target_group_key = "rewards"
    #     }
    #   }
    # }
  )

  target_groups = {
    rewards = {
      name_prefix       = "rw-"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false

      health_check = {
        enabled  = true
        path     = "/"
        port     = "traffic-port"
        protocol = "HTTP"
        matcher  = "200-399"
      }
    }
  }

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
  tags = merge(var.tags, {
    Name = "${var.name}-alb-public"
  })
}
