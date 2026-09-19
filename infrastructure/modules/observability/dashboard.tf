resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.name}-operations"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 2

        properties = {
          markdown = "# ${var.name} Operations Dashboard\nALB, ECS and PostgreSQL service health."
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 2
        width  = 12
        height = 6

        properties = {
          title   = "ALB Traffic and Errors"
          region  = data.aws_region.current.region
          view    = "timeSeries"
          stacked = false
          period  = 60
          stat    = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              var.load_balancer_arn_suffix,
              {
                label = "Requests"
              }
            ],
            [
              ".",
              "HTTPCode_ELB_5XX_Count",
              ".",
              ".",
              {
                label = "ALB 5xx"
              }
            ],
            [
              ".",
              "HTTPCode_Target_5XX_Count",
              ".",
              ".",
              {
                label = "Target 5xx"
              }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 2
        width  = 12
        height = 6

        properties = {
          title   = "ALB Target Health and Latency"
          region  = data.aws_region.current.region
          view    = "timeSeries"
          stacked = false
          period  = 60

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              var.load_balancer_arn_suffix,
              {
                stat  = "Average"
                label = "Average response time"
              }
            ],
            [
              ".",
              "UnHealthyHostCount",
              ".",
              ".",
              "TargetGroup",
              var.target_group_arn_suffix,
              {
                stat  = "Maximum"
                label = "Unhealthy targets"
              }
            ],
            [
              ".",
              "HealthyHostCount",
              ".",
              ".",
              ".",
              ".",
              {
                stat  = "Minimum"
                label = "Healthy targets"
              }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6

        properties = {
          title   = "Frontend ECS Utilization"
          region  = data.aws_region.current.region
          view    = "timeSeries"
          stacked = false
          period  = 60
          stat    = "Average"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }

          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              var.ecs_cluster_name,
              "ServiceName",
              var.frontend_service_name,
              {
                label = "CPU"
              }
            ],
            [
              ".",
              "MemoryUtilization",
              ".",
              ".",
              ".",
              ".",
              {
                label = "Memory"
              }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 8
        width  = 12
        height = 6

        properties = {
          title   = "Backend ECS Utilization"
          region  = data.aws_region.current.region
          view    = "timeSeries"
          stacked = false
          period  = 60
          stat    = "Average"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }

          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              var.ecs_cluster_name,
              "ServiceName",
              var.backend_service_name,
              {
                label = "CPU"
              }
            ],
            [
              ".",
              "MemoryUtilization",
              ".",
              ".",
              ".",
              ".",
              {
                label = "Memory"
              }
            ]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 14
        width  = 24
        height = 6

        properties = {
          title   = "PostgreSQL RDS Health"
          region  = data.aws_region.current.region
          view    = "timeSeries"
          stacked = false
          period  = 60
          stat    = "Average"

          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              var.database_instance_id,
              {
                label = "CPU utilization",
                yAxis = "left"
              }
            ],
            [
              ".",
              "DatabaseConnections",
              ".",
              ".",
              {
                label = "Connections",
                yAxis = "right"
              }
            ],
            [
              ".",
              "FreeStorageSpace",
              ".",
              ".",
              {
                label = "Free storage",
                yAxis = "right"
              }
            ]
          ]
        }
      }
    ]
  })
}