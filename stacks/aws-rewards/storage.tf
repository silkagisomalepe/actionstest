locals {
  bucket_names = [
    "${var.name}-ansible-artifacts",
  ]
}

module "s3-buckets" {
  source = "../../modules/aws-nst-s3"

  for_each = toset(local.bucket_names)
  name     = each.value
  tags     = var.tags
}
