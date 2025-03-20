resource "aws_instance" "web" {
  ami                    = var.custom_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.application_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name # Attach IAM profile

  user_data = <<-EOF
    #!/bin/bash
    rm -f /opt/webapp/.env

    cat <<EOT > /opt/webapp/.env
    DB_HOST=${aws_db_instance.postgres_instance.address}
    DB_NAME=${var.db_name}
    DB_USER=${var.db_user}
    DB_PASSWORD=${var.db_password}
    DB_PORT=${var.db_port}
    AWS_BUCKET_NAME=${aws_s3_bucket.webapp_bucket.id}
    AWS_REGION=${var.aws_region}
    AWS_ACCESS_KEY_ID=${var.aws_access_key}
    AWS_SECRET_ACCESS_KEY=${var.aws_secret_key}
    EOT

    chown csye6225:csye6225 /opt/webapp/.env
    chmod 640 /opt/webapp/.env

    sleep 60
    sudo systemctl restart webapp.service

    echo ".env file created and secured."
  EOF

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  # Doesn't protect from accidental termination
  disable_api_termination = false

  tags = {
    Name = "web-application-instance"
  }
}
