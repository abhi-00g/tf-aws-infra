# Generate random password for RDS
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%^&*()-_=+[]{}|:,.?"
}

# Generate random suffix for Secret Name
resource "random_id" "db_secret_suffix" {
  byte_length = 4
}

# Create RDS Password Secret with random name
resource "aws_secretsmanager_secret" "db_password_secret" {
  name        = "rds-db-password-${random_id.db_secret_suffix.hex}" # Random secret name
  description = "Database password for RDS instance"
  kms_key_id  = aws_kms_key.secret_key.arn
}

# Add version (password value) to Secret
resource "aws_secretsmanager_secret_version" "db_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_password_secret.id
  secret_string = random_password.db_password.result
}
