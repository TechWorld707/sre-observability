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
  name               = "${var.name}-frontend-task-execution"
  description        = "Allows ECS to start the frontend task and deliver container logs."
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-frontend-task-execution"
      Tier = "frontend"
    }
  )
}

data "aws_iam_policy_document" "task_execution" {
  statement {
    sid    = "WriteFrontendContainerLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.frontend.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "task_execution" {
  name   = "${var.name}-frontend-task-execution"
  role   = aws_iam_role.task_execution.id
  policy = data.aws_iam_policy_document.task_execution.json
}

resource "aws_iam_role" "task" {
  name               = "${var.name}-frontend-task"
  description        = "Runtime identity for the frontend container."
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-frontend-task"
      Tier = "frontend"
    }
  )
}

data "aws_iam_policy_document" "ecs_execute_command" {
  count = var.enable_execute_command ? 1 : 0

  statement {
    sid    = "AllowECSExecSession"
    effect = "Allow"

    #checkov:skip=CKV_AWS_356: Systems Manager Messages actions do not support resource-level permissions.
    #checkov:skip=CKV_AWS_111: These permissions are limited to the ECS task role and are required only when ECS Exec is enabled.
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

  name   = "${var.name}-frontend-ecs-exec"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.ecs_execute_command[0].json
}