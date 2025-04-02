#!/bin/bash

# Create .env file
cat <<EOT > /opt/webapp/.env
DB_HOST=${db_host}
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_PORT=${db_port}
AWS_BUCKET_NAME=${aws_bucket_name}
AWS_REGION=${aws_region}
EOT

chown csye6225:csye6225 /opt/webapp/.env
chmod 640 /opt/webapp/.env

# Create CloudWatch log file
touch /var/log/app.log
chown csye6225:csye6225 /var/log/app.log
chmod 644 /var/log/app.log

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Restart app
sleep 60
systemctl restart webapp