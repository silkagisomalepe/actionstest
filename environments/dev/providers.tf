provider "aws" {
  region = var.aws_region
}

provider "awscc" {
  alias  = "awscccurrent"
  region = var.aws_region
}
