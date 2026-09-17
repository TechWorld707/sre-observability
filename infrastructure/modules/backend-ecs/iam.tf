data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    sid     = "AllowECSTasks"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.name}-backend-task-execution"
  description        = "Allows ECS to start the backend task, retrieve its database secret and deliver logs."
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-backend-task-execution"
      Tier = "backend"
    }
  )
}

data "aws_iam_policy_document" "task_execution" {
  statement {
    sid    = "WriteBackendContainerLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.backend.arn}:*"
    ]
  }

  statement {
    sid       = "ReadDatabaseURL"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.database_url_secret_arn]
  }

  statement {
    sid       = "DecryptDatabaseSecret"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [var.database_secret_kms_key_arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "secretsmanager.${data.aws_region.current.region}.${data.aws_partition.current.dns_suffix}"
      ]
    }
  }
}

resource "aws_iam_role_policy" "task_execution" {
  name   = "${var.name}-backend-task-execution"
  role   = aws_iam_role.task_execution.id
  policy = data.aws_iam_policy_document.task_execution.json
}

resource "aws_iam_role" "task" {
  name               = "${var.name}-backend-task"
  description        = "Runtime identity for the backend application."
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-backend-task"
      Tier = "backend"
    }
  )
}

data "aws_iam_policy_document" "ecs_execute_command" {
  count = var.enable_execute_command ? 1 : 0

  statement {
    sid    = "AllowECSExecSession"
    effect = "Allow"

    #checkov:skip=CKV_AWS_356: Systems Manager Messages actions do not support resource-level permissions.
    #checkov:skip=CKV_AWS_111: These permissions are limited to the backend task role and are required only when ECS Exec is enabled.
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_execute_command" {
  count = var.enable_execute_command ? 1 : 0

  name   = "${var.name}-backend-ecs-exec"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.ecs_execute_command[0].json
}