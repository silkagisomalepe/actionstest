module "vpc" {
  source                       = "terraform-aws-modules/vpc/aws"
  version                      = "~> 5.2.0"
  name                         = var.vpc_name
  cidr                         = var.cidr
  azs                          = local.azs
  public_subnets               = local.public_subnets
  private_subnets              = local.private_subnets
  enable_nat_gateway           = var.enable_nat_gateway
  single_nat_gateway           = var.single_nat_gateway
  enable_dns_hostnames         = var.enable_dns_hostname
  enable_dns_support           = var.enable_dns_support
  create_database_subnet_group = var.create_database_subnet_group

  public_subnet_names = [
    "${var.name}-public-subnet-a",
    "${var.name}-public-subnet-b",
    "${var.name}-public-subnet-c",
  ]
  private_subnet_names = [
    "${var.name}-ec2-private-subnet-a",
    "${var.name}-ec2-private-subnet-b",
    "${var.name}-ec2-private-subnet-c",
  ]
  database_subnet_names = [
    "${var.name}-db-a",
    "${var.name}-db-b",
    "${var.name}-db-c",
  ]

  public_route_table_tags = {
    Name = "${var.name}-public-route-table"
  }
  private_route_table_tags = {
    Name = "${var.name}-private-route-table"
  }
  default_network_acl_tags = {
    Name = "${var.name}-nacl"
  }
  igw_tags = {
    Name = "${var.name}-internet-gateway"
  }
  nat_gateway_tags = {
    Name = "${var.name}-nat-gateway"
  }
  nat_eip_tags = {
    Name = "${var.name}-eip"
  }
  dhcp_options_tags = {
    Name = "${var.name}-dhcp-option-set"
  }
}

module "vpc-flowlogs" {
  source             = "../../modules/aws-nst-flow-logs"
  name               = "${var.name}-flowlogs"
  vpc_id             = module.vpc.vpc_id
  access_logs_bucket = var.access_logs_bucket
  service_tags       = var.tags
}
