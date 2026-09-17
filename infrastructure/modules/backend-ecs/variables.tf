variable "name" {
  description = "Name prefix used for backend ECS resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The name must not be empty."
  }
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster hosting the backend service."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:ecs:", var.cluster_arn))
    error_message = "The cluster_arn must be a valid ECS cluster ARN."
  }
}

variable "private_subnet_ids" {
  description = "Private application subnet IDs used by backend ECS tasks."
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
  description = "Security group attached to backend ECS tasks."
  type        = string

  validation {
    condition     = can(regex("^sg-[0-9a-f]+$", var.security_group_id))
    error_message = "The security_group_id must be a valid AWS security group ID."
  }
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

variable "container_image" {
  description = "Immutable GHCR image used by the backend service."
  type        = string

  validation {
    condition = (
      startswith(var.container_image, "ghcr.io/") &&
      !endswith(var.container_image, ":latest")
    )
    error_message = "The backend image must be a GHCR image with an immutable tag, not latest."
  }
}

variable "database_url_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DATABASE_URL."
  type        = string

  validation {
    condition = can(
      regex(
        "^arn:aws[a-zA-Z-]*:secretsmanager:",
        var.database_url_secret_arn
      )
    )
    error_message = "The database URL must reference a valid Secrets Manager secret ARN."
  }
}

variable "database_secret_kms_key_arn" {
  description = "ARN of the KMS key encrypting the database connection secret."
  type        = string

  validation {
    condition     = can(regex("^arn:aws[a-zA-Z-]*:kms:", var.database_secret_kms_key_arn))
    error_message = "The database secret KMS key ARN must be a valid KMS key ARN."
  }
}

variable "container_port" {
  description = "Port exposed by the FastAPI backend container."
  type        = number
  default     = 8000

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "The container port must be between 1 and 65535."
  }
}

variable "desired_count" {
  description = "Desired number of backend ECS tasks."
  type        = number
  default     = 2

  validation {
    condition     = var.desired_count >= 2
    error_message = "At least two backend tasks are required for multi-AZ availability."
  }
}

variable "task_cpu" {
  description = "Fargate CPU units allocated to the backend task."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate memory in MiB allocated to the backend task."
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "Number of days to retain backend CloudWatch logs."
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 365
    error_message = "Backend logs must be retained for at least 365 days."
  }
}

variable "enable_execute_command" {
  description = "Whether ECS Exec is enabled for controlled troubleshooting."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to backend ECS resources."
  type        = map(string)
  default     = {}
}