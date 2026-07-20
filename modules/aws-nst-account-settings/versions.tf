terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    awscc = {
      source                = "hashicorp/awscc"
      version               = ">= 1.0"
      configuration_aliases = [awscc.awscccurrent]
    }
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.20.0"
    }
  }
}
