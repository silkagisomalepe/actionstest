aws_region                  = "eu-west-1"
environment                 = "dev"
monthly_budget_limit_amount = 100

vpc_name           = "rewards-dev"
cidr               = "10.0.0.0/16"
az_count           = 3
single_nat_gateway = true

tags = {
  Environment = "dev"
  Service     = "rewards"
  Owner       = "kagiso-malepe"
  CostCenter  = "payments"
}
