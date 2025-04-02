variable "aws_region" {
  description = "AWS region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile (demo or dev)"
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "AWS Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "custom_ami" {
  description = "Custom AMI ID from Packer"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.small"
}

# variable "app_port" {
#   description = "Port the web application runs on"
#   type        = number
#   default     = 3000
# }

variable "db_password" {
  description = "Password"
  type        = string
  default     = "password"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "user"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "name"
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "domain_name" {
  description = "The domain name (dev.yourdomain.com or demo.yourdomain.com)"
  type        = string
  default     = "id"
}

variable "asg_desired_capacity" {
  description = "Desired number of instances"
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of instances"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances"
  type        = number
}
variable "asg_scale_up_threshold" {
  description = "CPU % threshold for scaling up"
  type        = number
}

variable "asg_scale_down_threshold" {
  description = "CPU % threshold for scaling down"
  type        = number
}

variable "asg_cooldown" {
  description = "Cooldown time for scaling actions (seconds)"
  type        = number
}

