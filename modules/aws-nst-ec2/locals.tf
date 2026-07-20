locals {
  ec2_instances = {
    for obj in var.ec2 : obj.name => obj
  }
}
