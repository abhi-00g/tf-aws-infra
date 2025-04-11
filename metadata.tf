# Generate random suffix for metadata secret
resource "random_id" "metadata_secret_suffix" {
  byte_length = 4
}

# Create metadata secret in Secrets Manager
resource "aws_secretsmanager_secret" "asg_metadata" {
  name        = "launch-data-${random_id.metadata_secret_suffix.hex}"
  description = "Stores Launch Template and ASG metadata for instance refresh automation"
  kms_key_id  = aws_kms_key.secret_key.arn
}

# Add metadata as secret string
resource "aws_secretsmanager_secret_version" "asg_metadata_version" {
  secret_id = aws_secretsmanager_secret.asg_metadata.id

  secret_string = jsonencode({
    launch_template_id      = aws_launch_template.web_lt.id
    launch_template_name    = aws_launch_template.web_lt.name
    launch_template_version = data.aws_launch_template.web_lt_data.latest_version
    autoscaling_group_name  = aws_autoscaling_group.web_asg.name
  })

  depends_on = [
    aws_launch_template.web_lt,
    aws_autoscaling_group.web_asg
  ]
}

# Data source to get latest launch template version
data "aws_launch_template" "web_lt_data" {
  name = aws_launch_template.web_lt.name
}
