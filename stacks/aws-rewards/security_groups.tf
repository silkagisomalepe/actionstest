module "alb-public-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  vpc_id      = module.vpc.vpc_id
  name        = "${var.name}-alb-public-sg"
  description = "${var.name}-alb-public-sg"

  ingress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      description = "Internet-ALB-HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "https-443-tcp"
      description = "Internet-ALB-HTTPS"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      description              = "ALB-EC2-HTTP"
      source_security_group_id = module.ecs-private-sg.security_group_id
    },
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-alb-public-sg"
  })
}

module "ec2-private-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.2"

  vpc_id      = module.vpc.vpc_id
  name        = "${var.name}-ec2-private-sg"
  description = "${var.name}-ec2-private-sg"

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      description              = "ALB-Private-EC2-HTTP"
      source_security_group_id = module.alb-public-sg.security_group_id
    },
  ]

  egress_with_source_security_group_id = [
    {
      description              = "EC2-PostgreSQL-TCP"
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = module.db-private-sg.security_group_id
    },
    {
      description              = "EC2-ElastiCache-TCP"
      from_port                = 6379
      to_port                  = 6379
      protocol                 = "tcp"
      source_security_group_id = module.cache-private-sg.security_group_id
    }
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-ec2-private-sg"
  })
}
