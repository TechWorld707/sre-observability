data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  common_tags = merge(
    var.tags,
    {
      Module = "backend-ecs"
      Tier   = "backend"
    }
  )
}

data "aws_iam_policy_document" "backend_logs_kms" {
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
        "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ecs/${var.name}/backend*"
      ]
    }
  }
}

resource "aws_kms_key" "backend_logs" {
  description             = "Encrypts backend ECS and Service Connect CloudWatch logs."
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.backend_logs_kms.json

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-backend-logs"
    }
  )
}

resource "aws_kms_alias" "backend_logs" {
  name          = "alias/${var.name}-backend-logs"
  target_key_id = aws_kms_key.backend_logs.key_id
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/aws/ecs/${var.name}/backend"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.backend_logs.arn

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-backend"
    }
  )
}

resource "aws_ecs_service" "backend" {
  name            = "${var.name}-backend"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_count

  launch_type      = "FARGATE"
  platform_version = "LATEST"

  availability_zone_rebalancing = "ENABLED"
  enable_execute_command        = var.enable_execute_command
  enable_ecs_managed_tags       = true
  propagate_tags                = "SERVICE"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  service_connect_configuration {
    enabled   = true
    namespace = var.service_connect_namespace_arn

    log_configuration {
      log_driver = "awslogs"

      options = {
        awslogs-group         = aws_cloudwatch_log_group.backend.name
        awslogs-region        = data.aws_region.current.region
        awslogs-stream-prefix = "service-connect"
      }
    }

    service {
      port_name      = "backend-http"
      discovery_name = "backend"

      client_alias {
        dns_name = "backend"
        port     = var.container_port
      }
    }
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-backend"
    }
  )

  depends_on = [
    aws_iam_role_policy.task_execution
  ]
}