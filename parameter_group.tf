resource "aws_db_parameter_group" "postgresql_parameter_group" {
  name        = "postgresql-pg"
  family      = "postgres17"
  description = "Custom parameter group for PostgreSQL RDS"

  parameter {
    name         = "rds.force_ssl"
    value        = "0"
    apply_method = "pending-reboot"
  }
  parameter {
    name         = "password_encryption"
    value        = "scram-sha-256"
    apply_method = "pending-reboot"
  }
}
