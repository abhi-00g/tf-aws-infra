resource "aws_db_parameter_group" "postgresql_parameter_group" {
  name        = "postgresql-pg"
  family      = "postgres17"
  description = "Custom parameter group for PostgreSQL RDS"

}
