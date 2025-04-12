resource "aws_security_group" "application_security_group" {
  name   = "application-security-group"
  vpc_id = aws_vpc.main_vpc.id

  # Ingress rules for allowing incoming traffic
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from anywhere
  # }

  # Allow application port access
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
    description     = "Allow app traffic from Load Balancer only"
  }

  # Egress rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "application-security-group"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "db-security-group"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = aws_vpc.main_vpc.id

  # Allow inbound PostgreSQL connections ONLY from the application security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application_security_group.id] # Only allow EC2 app SG
    description     = "Allow PostgreSQL traffic from EC2 instances"
  }

  # Allow outbound traffic (RDS can respond to incoming requests)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outgoing traffic for updates, backups
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "db-security-group"
  }
}

resource "aws_security_group" "lb_sg" {
  name   = "lb-security-group"
  vpc_id = aws_vpc.main_vpc.id

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #   description = "Allow HTTP from anywhere"
  # }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "lb-security-group"
  }
}
