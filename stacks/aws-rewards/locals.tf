locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  public_subnets = [
    cidrsubnet(var.cidr, 8, 1),
    cidrsubnet(var.cidr, 8, 2),
    cidrsubnet(var.cidr, 8, 3),
  ]

  private_subnets = [
    cidrsubnet(var.cidr, 8, 11),
    cidrsubnet(var.cidr, 8, 12),
    cidrsubnet(var.cidr, 8, 13),
  ]

  ec2_base = [
    {
      name                   = "rewards"
      type                   = "t4g.micro"
      ami                    = data.aws_ami.ubuntu_arm64.id
      subnet_id              = module.vpc.private_subnets[0]
      vpc_zone_subnet_ids    = [module.vpc.private_subnets[0]]
      volume_size            = 50
      security_group_ids     = [module.ec2-private-sg.security_group_id]
      target_group_arns      = [module.alb-public.target_groups["rewards"].arn]
      alerts_topic_arn       = ""
      enable_autoscaling     = true
      enable_ssm             = true
      desired_capacity       = 1
      min_size               = 1
      max_size               = 2
      target_cpu_utilization = 70
    },
  ]
}
