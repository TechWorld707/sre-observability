data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  common_tags = merge(
    var.tags,
    {
      Module = "frontend-ecs"
      Tier   = "frontend"
    }
  )
}

data "aws_iam_policy_document" "frontend_logs_kms" {
  #checkov:skip=CKV_AWS_109: The administrative statement is restricted to this account's root principal and applies only to the KMS key receiving this key policy.
  #checkov:skip=CKV_AWS_111: CloudWatch Logs write access is restricted by service principal, Region, account and log-group encryption context.
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
        "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ecs/${var.name}/frontend*"
      ]
    }
  }
}

resource "aws_kms_key" "frontend_logs" {
  description             = "Encrypts frontend ECS and ECS Exec CloudWatch logs."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.frontend_logs_kms.json

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-frontend-logs"
    }
  )
}

resource "aws_kms_alias" "frontend_logs" {
  name          = "alias/${var.name}-frontend-logs"
  target_key_id = aws_kms_key.frontend_logs.key_id
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/aws/ecs/${var.name}/frontend"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.frontend_logs.arn

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-frontend"
    }
  )
}

resource "aws_cloudwatch_log_group" "ecs_exec" {
  name              = "/aws/ecs/${var.name}/frontend-exec"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.frontend_logs.arn

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-frontend-exec"
    }
  )
}

resource "aws_ecs_cluster" "application" {
  name = "${var.name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.frontend_logs.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_exec.name
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-cluster"
    }
  )
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.name}-frontend"
  cluster         = aws_ecs_cluster.application.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.desired_count

  launch_type      = "FARGATE"
  platform_version = "LATEST"

  availability_zone_rebalancing = "ENABLED"
  enable_execute_command        = var.enable_execute_command
  enable_ecs_managed_tags       = true
  propagate_tags                = "SERVICE"

  health_check_grace_period_seconds = 60

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "frontend"
    container_port   = var.container_port
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-frontend"
    }
  )

  depends_on = [
    aws_iam_role_policy.task_execution
  ]
}