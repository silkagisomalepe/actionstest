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
      source_security_group_id = module.ec2-private-sg.security_group_id
    },
  ]

  tags = merge(var.tags, {
    Name = "${var.name}-alb-public-sg"
  })
}

#trivy:ignore:AWS-0104
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

  egress_with_cidr_blocks = [
    {
      description = "EC2-Internet-HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "DNS-lookup-TCP"
      from_port   = 53
      to_port     = 53
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "DNS-lookup-UDP"
      from_port   = 53
      to_port     = 53
      protocol    = "udp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = merge(var.tags, {
    Name = "${var.name}-ec2-private-sg"
  })
}
