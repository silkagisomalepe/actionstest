#trivy:ignore:AWS-0132
module "access-logs" {
  source          = "../../modules/aws-nst-access-logs"
  name            = "${var.name}-access-logs"
  alb_logs_prefix = "alb"
}

module "config" {
  source                        = "../../modules/aws-nst-config"
  is_enabled                    = true
  config_name                   = "${var.name}-config"
  environment                   = var.environment
  config_logs_prefix            = "config"
  config_delivery_frequency     = "Six_Hours"
  include_global_resource_types = true
  access_logs_bucket            = module.access-logs.bucket
}

module "cloudtrail" {
  source                        = "../../modules/aws-nst-cloudtrail"
  name                          = "${var.name}-cloudtrail"
  environment                   = var.environment
  enable_logging                = true
  enable_log_file_validation    = true
  is_multi_region_trail         = true
  include_global_service_events = true
  access_logs_bucket            = module.access-logs.bucket
}

module "account_settings" {
  source = "../../modules/aws-nst-account-settings"

  providers = {
    awscc.awscccurrent = awscc.awscccurrent
  }

  name                             = var.name
  budget_name                      = "${var.name}-budget"
  limit_amount                     = var.monthly_budget_limit_amount
  delete_default_vpc               = true
  budget_alerts_emails             = var.budget_alerts_emails
  budget_alerts_escalations_emails = var.budget_alerts_escalations_emails
  minimum_password_length          = "32"
}
