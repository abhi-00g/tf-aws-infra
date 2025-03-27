resource "aws_instance" "web" {
  ami                    = var.custom_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.application_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  user_data = <<EOF
#!/bin/bash

# Remove old .env if it exists
rm -f /opt/webapp/.env

# Write new .env
cat <<EOT > /opt/webapp/.env
DB_HOST=${aws_db_instance.postgres_instance.address}
DB_NAME=${var.db_name}
DB_USER=${var.db_user}
DB_PASSWORD=${var.db_password}
DB_PORT=${var.db_port}
AWS_BUCKET_NAME=${aws_s3_bucket.webapp_bucket.id}
AWS_REGION=${var.aws_region}
EOT

# Set permissions for .env
chown csye6225:csye6225 /opt/webapp/.env
chmod 640 /opt/webapp/.env

# Create CloudWatch log file
touch /var/log/app.log
chown csye6225:csye6225 /var/log/app.log
chmod 644 /var/log/app.log

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Restart the webapp service
sleep 60
systemctl restart webapp.service

echo ".env file created and secured."
EOF

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  disable_api_termination = false

  tags = {
    Name = "web-application-instance"
  }
}
