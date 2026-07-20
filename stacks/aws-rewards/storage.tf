locals {
  bucket_names = [
    "${workload_name}-ansible-artifacts",
  ]
}

module "s3-buckets" {
  source = "../../modules/aws-so-s3"

  for_each = toset(local.bucket_names)
  name     = each.value
  tags     = var.tags
}
