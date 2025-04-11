# Fetch AWS Account Info
data "aws_caller_identity" "current" {}

# EC2 Volume Encryption KMS Key
resource "aws_kms_key" "ec2_key" {
  description             = "KMS Key for encrypting EC2 volumes"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 20

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "ec2-key-policy",
    Statement = [
      {
        Sid    = "Enable IAM Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow administration of EC2 key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/${var.user_name}"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow use of EC2 key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/${var.user_name}"
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "ec2_key_alias" {
  name          = "alias/ec2-key"
  target_key_id = aws_kms_key.ec2_key.id
}

# RDS Storage Encryption KMS Key
resource "aws_kms_key" "rds_key" {
  description             = "KMS Key for encrypting RDS instance storage"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 20

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "rds-key-policy",
    Statement = [
      {
        Sid    = "Enable IAM Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow administration of RDS key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/${var.user_name}"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow use of RDS key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/${var.user_name}"
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/rds-key"
  target_key_id = aws_kms_key.rds_key.id
}

# S3 Bucket Encryption KMS Key
resource "aws_kms_key" "s3_key" {
  description             = "KMS Key for encrypting S3 bucket objects"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 20

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "s3-key-policy",
    Statement = [
      {
        Sid    = "Enable IAM Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow administration of S3 key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/${var.user_name}"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow EC2 role for S3 operations",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:role/ec2_s3_access_role"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow S3 service for lifecycle/replication",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow S3 grants for internal management",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        Resource = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = true
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.s3_key.id
}

# Secrets Manager Encryption KMS Key
resource "aws_kms_key" "secret_key" {
  description             = "KMS Key for encrypting Secrets Manager secrets"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 20

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "secret-key-policy",
    Statement = [
      {
        Sid    = "Enable IAM Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow administration of Secret key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/${var.user_name}"
        },
        Action = [
          "kms:ReplicateKey",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      },
      {
        Sid    = "Allow use of Secret key",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:user/${var.user_name}"
        },
        Action = [
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "secret_key_alias" {
  name          = "alias/secret-key"
  target_key_id = aws_kms_key.secret_key.id
}
