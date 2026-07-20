resource "aws_iam_role" "server_role" {
  name               = "${var.service_name}-server-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json
  tags = merge(var.service_tags, {
    Name  = "${var.service_name}-server-role"
    Owner = var.service_name
  })
}

resource "aws_iam_instance_profile" "server_profile" {
  name = "${var.service_name}-server-profile"
  role = aws_iam_role.server_role.name
  tags = merge(var.service_tags, {
    Name = "${var.service_name}-server-profile"
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.service_name}-server-policy"
  description = "Policy used for EC2 instances"
  policy      = data.aws_iam_policy_document.ec2.json
  tags = merge(var.service_tags, {
    Name = "${var.service_name}-server-policy"
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.server_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.server_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_launch_template" "ec2" {
  for_each = local.ec2_instances

  name          = "${var.service_name}-${each.value.name}"
  description   = "${var.service_name}-${each.value.name} Server"
  image_id      = each.value.ami
  instance_type = each.value.type
  key_name      = "${var.service_name}-${each.value.name}-kp"

  ebs_optimized = true

  iam_instance_profile {
    name = aws_iam_instance_profile.server_profile.name
  }

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    subnet_id       = each.value.subnet_id
    security_groups = each.value.security_group_ids
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = each.value.volume_size
      volume_type           = "gp3"
    }
  }

  user_data = each.value.user_data != "" ? each.value.user_data : (
    each.value.enable_ssm ? filebase64("${path.module}/user_data.txt") : null
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.service_tags, {
      Name = "${var.service_name}-${each.value.name}"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.service_tags, {
      Name = "${var.service_name}-${each.value.name}"
      env  = "backup"
    })
  }

  update_default_version = true

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_instance_profile.server_profile
  ]

  tags = merge(var.service_tags, {
    Name = "${var.service_name}-${each.value.name}"
  })
}

resource "aws_autoscaling_group" "ec2" {
  for_each = { for k, v in local.ec2_instances : k => v if v.enable_autoscaling }

  name = "${var.service_name}-${each.value.name}-asg"

  desired_capacity = each.value.desired_capacity
  max_size         = each.value.max_size
  min_size         = each.value.min_size

  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.ec2[each.value.name].id
    version = "$Latest"
  }

  vpc_zone_identifier = each.value.vpc_zone_subnet_ids
  target_group_arns   = each.value.target_group_arns

  enabled_metrics = [
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
    "WarmPoolDesiredCapacity",
    "WarmPoolMinSize",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolTotalCapacity",
    "WarmPoolWarmedCapacity",
  ]

  depends_on = [
    aws_launch_template.ec2
  ]

  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "${var.service_name}-${each.value.name}-asg"
  }

  tag {
    key                 = "Environment"
    propagate_at_launch = false
    value               = var.service_tags["Environment"]
  }

  tag {
    key                 = "Terraform"
    propagate_at_launch = false
    value               = true
  }
}

resource "aws_autoscaling_policy" "cpu" {
  for_each = { for k, v in local.ec2_instances : k => v if v.enable_autoscaling }

  name                   = "${var.service_name}-${each.value.name}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.ec2[each.key].name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = each.value.target_cpu_utilization
  }
}
