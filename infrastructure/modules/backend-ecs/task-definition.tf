resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.name}-backend"
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

  volume {
    name = "backend-tmp"
  }

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.container_image
      essential = true
      user      = "appuser"

      portMappings = [
        {
          name          = "backend-http"
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = var.database_url_secret_arn
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "backend-tmp"
          containerPath = "/tmp"
          readOnly      = false
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "python -c \"import urllib.request; urllib.request.urlopen('http://localhost:${var.container_port}/healthz', timeout=2)\" || exit 1"
        ]

        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 30
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "backend"
        }
      }

      readonlyRootFilesystem = true

      linuxParameters = {
        initProcessEnabled = true
      }

      stopTimeout = 30
    }
  ])

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-backend"
    }
  )
}