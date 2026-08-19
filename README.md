# AWS Infrastructure (Terraform)

Terraform configuration for a production-grade AWS infrastructure supporting the [Cloud-Native Web Application](https://github.com/abhi-00g/webapp). Provisions a complete networking stack, auto-scaled compute, managed database, encrypted storage, load balancing, DNS, and KMS encryption — all as code.

> **Application repo:** [webapp](https://github.com/abhi-00g/webapp) — The Node.js backend API that runs on this infrastructure.

## What Gets Provisioned

### Networking
- **VPC** with configurable CIDR block
- **3 public subnets** and **3 private subnets**, each in a different availability zone
- **Internet Gateway** attached to the VPC
- **Public and private route tables** with appropriate routing rules

### Compute
- **Auto Scaling Group** (min 3, max 5 instances) using a Launch Template with the latest custom AMI
- **Scale-up policy** when average CPU > 5%, **scale-down policy** when CPU < 3%
- EC2 instances run in public subnets with IAM instance profiles (no hardcoded credentials)

### Load Balancing
- **Application Load Balancer** (ALB) accepting HTTPS traffic on port 443
- SSL/TLS termination at the ALB using ACM certificates
- Health check routing to the application's `/healthz` endpoint

### Database
- **RDS PostgreSQL** instance deployed in private subnets (not publicly accessible)
- Custom **RDS parameter group**
- Database credentials auto-generated and stored in **AWS Secrets Manager**

### Storage
- **S3 bucket** (UUID-named, private) for file uploads
- AES-256 encryption with customer-managed KMS key
- Lifecycle policy: STANDARD → STANDARD_IA after 30 days

### Security
- **Load Balancer Security Group** — ingress on ports 80, 443 from anywhere
- **Application Security Group** — ingress only from the load balancer security group
- **Database Security Group** — ingress only from the application security group
- **KMS keys** (90-day rotation) for EC2, RDS, S3, and Secrets Manager
- **IAM roles and policies** following the principle of least privilege

### DNS & SSL
- **Route 53** A record (alias) pointing the domain to the ALB
- **ACM certificate** for SSL/TLS termination
- Support for imported SSL certificates (Namecheap, etc.)

### Observability
- **IAM roles** for CloudWatch Agent on EC2 instances
- CloudWatch configured via user data scripts at instance launch

## Terraform File Structure

```
├── main.tf               # VPC, subnets, Internet Gateway, route tables
├── provider.tf           # AWS provider configuration
├── variables.tf          # All configurable variables
├── outputs.tf            # Stack outputs
├── ec2.tf                # Launch template, user data
├── asg.tf                # Auto Scaling Group, scaling policies
├── alb.tf                # Application Load Balancer, target group, listener
├── rds_instance.tf       # RDS PostgreSQL instance
├── parameter_group.tf    # Custom RDS parameter group
├── s3.tf                 # S3 bucket, lifecycle policy, encryption
├── security_group.tf     # ALB, application, and database security groups
├── iam.tf                # IAM roles, policies, instance profiles
├── kms.tf                # KMS keys for EC2, RDS, S3, Secrets Manager
├── secrets.tf            # Secrets Manager for database credentials
├── route53.tf            # DNS A record alias to ALB
├── certificates.tf       # ACM certificate configuration
├── metadata.tf           # Instance metadata configuration
├── scripts/              # Helper scripts
└── .github/workflows/    # CI: terraform fmt + validate on PRs
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) v1.5+
- [AWS CLI](https://aws.amazon.com/cli/) configured with named profiles
- An AWS account with appropriate permissions
- A registered domain name with Route 53 hosted zone
- A custom AMI built with the [webapp](https://github.com/abhi-00g/webapp) Packer template

## Usage

```bash
# Initialize Terraform
terraform init

# Preview the infrastructure
terraform plan -var="aws_profile=demo"

# Create all resources
terraform apply -var="aws_profile=demo" --auto-approve

# Tear down all resources
terraform destroy -var="aws_profile=demo" --auto-approve
```

Multiple VPCs can be created in the same account and region without conflicts — all resource names are parameterized.

## SSL Certificate Import

To import an SSL certificate from an external provider:

```bash
aws acm import-certificate \
  --certificate fileb://certificate.crt \
  --private-key fileb://private.key \
  --certificate-chain fileb://ca-bundle.crt \
  --region us-east-1 \
  --profile demo
```

## CI (GitHub Actions)

Every pull request triggers:

1. `terraform fmt -check -recursive` — ensures consistent formatting
2. `terraform validate` — validates the configuration syntax

PRs cannot be merged if either check fails.
