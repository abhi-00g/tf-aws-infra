resource "aws_launch_template" "web_lt" {
  name          = "webapp-launch-template"
  image_id      = var.custom_ami
  instance_type = var.instance_type
  # key_name    = var.aws_key_name  # Optional, if SSH needed

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application_security_group.id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    db_name         = var.db_name,
    db_user         = var.db_user,
    db_host         = aws_db_instance.postgres_instance.address,
    db_port         = var.db_port,
    aws_bucket_name = aws_s3_bucket.webapp_bucket.id,
    aws_region      = var.aws_region,
    db_password     = random_password.db_password.result,
    secret_id       = aws_secretsmanager_secret.db_password_secret.name
  }))

  block_device_mappings {
    device_name = "/dev/sda1" # Standard and safest
    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_key.arn
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-instance"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                      = "webapp-asg"
  desired_capacity          = var.asg_desired_capacity
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  vpc_zone_identifier       = aws_subnet.public_subnets[*].id
  health_check_type         = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]

  tag {
    key                 = "Name"
    value               = "webapp-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale-up-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.asg_cooldown
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.asg_scale_up_threshold
  alarm_description   = "Alarm when CPU > threshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale-down-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.asg_cooldown
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "low-cpu-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.asg_scale_down_threshold
  alarm_description   = "Alarm when CPU < threshold"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
  alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]
}
