variable "name" {
  description = "Name prefix used for frontend ECS resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The name must not be empty."
  }
}

variable "private_subnet_ids" {
  description = "Private application subnet IDs used by frontend ECS tasks."
  type        = list(string)

  validation {
    condition = (
      length(var.private_subnet_ids) >= 2 &&
      alltrue([
        for subnet_id in var.private_subnet_ids :
        can(regex("^subnet-[0-9a-f]+$", subnet_id))
      ])
    )
    error_message = "Provide at least two valid private subnet IDs."
  }
}

variable "security_group_id" {
  description = "Security group attached to frontend ECS tasks."
  type        = string

  validation {
    condition     = can(regex("^sg-[0-9a-f]+$", var.security_group_id))
    error_message = "The security_group_id must be a valid AWS security group ID."
  }
}

variable "target_group_arn" {
  description = "ARN of the ALB target group used by the frontend service."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:elasticloadbalancing:", var.target_group_arn))
    error_message = "The target_group_arn must be a valid ALB target group ARN."
  }
}

variable "container_image" {
  description = "Immutable frontend container image, including its tag or digest."
  type        = string

  validation {
    condition     = length(trimspace(var.container_image)) > 0
    error_message = "The container image must not be empty."
  }
}

variable "container_port" {
  description = "Port exposed by the Nginx frontend container."
  type        = number
  default     = 80

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "The container port must be between 1 and 65535."
  }
}

variable "desired_count" {
  description = "Desired number of frontend ECS tasks."
  type        = number
  default     = 2

  validation {
    condition     = var.desired_count >= 1
    error_message = "The desired count must be at least one."
  }
}

variable "task_cpu" {
  description = "Fargate CPU units allocated to the frontend task."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate memory in MiB allocated to the frontend task."
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "Number of days to retain frontend CloudWatch logs."
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 365
    error_message = "Frontend logs must be retained for at least 365 days."
  }
}

variable "enable_execute_command" {
  description = "Whether ECS Exec is enabled for controlled troubleshooting."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to frontend ECS resources."
  type        = map(string)
  default     = {}
}

variable "service_connect_namespace_arn" {
  description = "ARN of the Service Connect namespace used for private service communication."
  type        = string

  validation {
    condition = can(
      regex(
        "^arn:aws[a-zA-Z-]*:servicediscovery:",
        var.service_connect_namespace_arn
      )
    )
    error_message = "The Service Connect namespace ARN must be a valid AWS Cloud Map ARN."
  }
}