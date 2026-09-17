resource "aws_ecs_task_definition" "frontend" {
  #checkov:skip=CKV_AWS_249: The existing standard Nginx image starts as root and binds to port 80; a non-root image will be introduced in a container-hardening change.
  #checkov:skip=CKV_AWS_336: The existing standard Nginx image requires writable runtime paths; read-only root filesystem support will be added during container hardening.

  family                   = "${var.name}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = tostring(var.task_cpu)
  memory = tostring(var.task_memory)

  execution_role_arn = aws_iam_role.task_execution.arn
  task_role_arn      = aws_iam_role.task.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          name          = "frontend-http"
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget --quiet --tries=1 --spider http://localhost:${var.container_port}/healthz || exit 1"
        ]

        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "frontend"
        }
      }

      readonlyRootFilesystem = false

      linuxParameters = {
        initProcessEnabled = true
      }

      stopTimeout = 30
    }
  ])

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-frontend"
    }
  )
}