# Fetch AWS Account Info
data "aws_caller_identity" "current" {}

# Random ID for alias suffix
resource "random_id" "kms_suffix" {
  byte_length = 4
}

# Corrected EC2 Volume Encryption KMS Key
resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 EBS encryption"
  deletion_window_in_days = 20
  enable_key_rotation     = true
  rotation_period_in_days = 90

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "AllowRootAccountToManageKey",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "AllowTerraformCallerToManageKeyPolicy",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : data.aws_caller_identity.current.arn
        },
        "Action" : [
          "kms:PutKeyPolicy",
          "kms:GetKeyPolicy",
          "kms:DeleteKeyPolicy"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowEC2InstanceRoleAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.ec2_role.name}"
        },
        "Action" : [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowEC2Service",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowSecretsManagerServiceUse",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "secretsmanager.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowRDSServiceUse",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "rds.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowS3ServiceUse",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "s3.amazonaws.com"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowTerraformUserToUseKey",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.user_name}"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowAutoScalingService",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "autoscaling.amazonaws.com"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AllowServiceLinkedRoleAutoScaling",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# Corrected EC2 KMS Alias
resource "aws_kms_alias" "ec2_key_alias" {
  name          = "alias/tf-ec2-encryption-key-${random_id.kms_suffix.hex}"
  target_key_id = aws_kms_key.ec2_key.key_id
}

# RDS Storage Encryption KMS Key
resource "aws_kms_key" "rds_key" {
  description             = "KMS Key for encrypting RDS instance storage"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 20
  policy                  = aws_kms_key.ec2_key.policy
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/tf-rds-encryption-key-${random_id.kms_suffix.hex}"
  target_key_id = aws_kms_key.rds_key.id
}


# S3 Bucket Encryption KMS Key
resource "aws_kms_key" "s3_key" {
  description             = "KMS Key for encrypting S3 bucket objects"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 20
  policy                  = aws_kms_key.ec2_key.policy
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/tf-s3-encryption-key-${random_id.kms_suffix.hex}"
  target_key_id = aws_kms_key.s3_key.id
}
# Secrets Manager Encryption KMS Key
resource "aws_kms_key" "secret_key" {
  description             = "KMS Key for encrypting Secrets Manager secrets"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 20
  policy                  = aws_kms_key.ec2_key.policy
}
resource "aws_kms_alias" "secret_key_alias" {
  name          = "alias/tf-secrets-encryption-key-${random_id.kms_suffix.hex}"
  target_key_id = aws_kms_key.secret_key.id
}
