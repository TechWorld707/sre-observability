data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  database_identifier = "${var.name}-postgres"

  common_tags = merge(
    var.tags,
    {
      Module = "postgresql"
      Tier   = "database"
    }
  )
}

data "aws_iam_policy_document" "database_kms" {
  #checkov:skip=CKV_AWS_109: The administrative statement is restricted to this account's root principal and applies only to the KMS key receiving this key policy.
  #checkov:skip=CKV_AWS_111: CloudWatch Logs access is restricted by service principal, Region, account and RDS log-group encryption context.
  #checkov:skip=CKV_AWS_356: AWS KMS key policies require Resource "*" because the policy is attached directly to one KMS key; it does not grant access to every account key.

  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchLogsEncryption"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.current.region}.${data.aws_partition.current.dns_suffix}"
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/rds/instance/${local.database_identifier}/*"
      ]
    }
  }
}

resource "aws_kms_key" "database" {
  description             = "Encrypts MiniShop PostgreSQL storage, logs and database connection secret."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.database_kms.json

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-database"
    }
  )
}

resource "aws_kms_alias" "database" {
  name          = "alias/${var.name}-database"
  target_key_id = aws_kms_key.database.key_id
}