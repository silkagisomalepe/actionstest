terraform {
  backend "s3" {
    region       = "eu-west-1"
    bucket       = "rewards-tf-iac-tfstate"
    key          = "dev/rewards-tf-iac.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
