module "aws-baseline" {
  source = "../../stacks/aws-baseline"

  providers = {
    awscc.awscccurrent = awscc.awscccurrent
  }

  name        = var.workload_name
  environment = var.environment

  monthly_budget_limit_amount      = var.monthly_budget_limit_amount
  budget_alerts_emails             = var.budget_alerts_emails
  budget_alerts_escalations_emails = var.budget_alerts_escalations_emails
}

module "aws-rewards" {
  source = "../../stacks/aws-rewards"

  name = var.workload_name

  access_logs_bucket = module.aws-baseline.access_logs_bucket

  vpc_name            = var.vpc_name
  cidr                = var.cidr
  az_count            = var.az_count
  enable_nat_gateway  = var.enable_nat_gateway
  single_nat_gateway  = var.single_nat_gateway
  enable_dns_hostname = var.enable_dns_hostname
  enable_dns_support  = var.enable_dns_support

  tags = var.tags
}
