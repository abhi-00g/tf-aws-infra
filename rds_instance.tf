resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-private-subnet-group"
  subnet_ids  = aws_subnet.private_subnets[*].id
  description = "Subnet group for RDS instances in private subnets"

  tags = {
    Name = "rds-private-subnet-group"
  }
}

resource "aws_db_instance" "postgres_instance" {
  identifier            = "csye6225"
  engine                = "postgres"
  engine_version        = "17"          # Adjust based on AWS available versions
  instance_class        = "db.t3.micro" # Cheapest available instance
  allocated_storage     = 20            # 20GB storage (adjust as needed)
  max_allocated_storage = 100           # Allows auto-scaling up to 100GB

  db_name              = "csye6225"
  username             = "csye6225"
  password             = random_password.db_password.result
  parameter_group_name = aws_db_parameter_group.postgresql_parameter_group.name

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]

  publicly_accessible = false # Ensures private access only
  multi_az            = false # No multi-AZ deployment

  skip_final_snapshot = true
  deletion_protection = false

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn

  tags = {
    Name = "PostgreSQL-RDS"
  }
}
