output "launch_template_ids" {
  description = "Map of instance name to launch template ID"
  value = {
    for k, v in aws_launch_template.ec2 : k => v.id
  }
}

output "autoscaling_group_names" {
  description = "Map of instance name to autoscaling group name"
  value = {
    for k, v in aws_autoscaling_group.ec2 : k => v.name
  }
}

output "iam_role_name" {
  description = "IAM role name for EC2 instances"
  value       = aws_iam_role.server_role.name
}
