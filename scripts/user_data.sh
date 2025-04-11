#!/bin/bash
echo "Setting up .env file..."

rm -f /opt/webapp/.env

SECRET_STRING=$(aws secretsmanager get-secret-value \
  --region "${aws_region}" \
  --secret-id "${secret_id}" \
  --query SecretString \
  --output text)

db_password=$(echo $SECRET_STRING | jq -r '.password')


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

touch /var/log/app.log
chown csye6225:csye6225 /var/log/app.log
chmod 644 /var/log/app.log

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

sleep 60

systemctl restart webapp