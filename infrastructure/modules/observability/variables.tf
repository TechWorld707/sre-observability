variable "name" {
  description = "Name prefix used for observability resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The name must not be empty."
  }
}

variable "load_balancer_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the frontend ALB target group."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  type        = string
}

variable "frontend_service_name" {
  description = "Name of the frontend ECS service."
  type        = string
}

variable "backend_service_name" {
  description = "Name of the backend ECS service."
  type        = string
}

variable "database_instance_id" {
  description = "Identifier of the PostgreSQL RDS instance."
  type        = string
}

variable "alarm_email" {
  description = "Optional email address that receives alarm notifications."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.alarm_email == null ||
      can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.alarm_email))
    )
    error_message = "alarm_email must be null or a valid email address."
  }
}

variable "ecs_cpu_threshold" {
  description = "ECS CPU utilization percentage that triggers an alarm."
  type        = number
  default     = 80

  validation {
    condition     = var.ecs_cpu_threshold > 0 && var.ecs_cpu_threshold <= 100
    error_message = "ecs_cpu_threshold must be between 1 and 100."
  }
}

variable "ecs_memory_threshold" {
  description = "ECS memory utilization percentage that triggers an alarm."
  type        = number
  default     = 80

  validation {
    condition     = var.ecs_memory_threshold > 0 && var.ecs_memory_threshold <= 100
    error_message = "ecs_memory_threshold must be between 1 and 100."
  }
}

variable "database_cpu_threshold" {
  description = "RDS CPU utilization percentage that triggers an alarm."
  type        = number
  default     = 80

  validation {
    condition     = var.database_cpu_threshold > 0 && var.database_cpu_threshold <= 100
    error_message = "database_cpu_threshold must be between 1 and 100."
  }
}

variable "database_free_storage_threshold_bytes" {
  description = "Minimum available RDS storage in bytes before an alarm is triggered."
  type        = number
  default     = 2147483648

  validation {
    condition     = var.database_free_storage_threshold_bytes > 0
    error_message = "database_free_storage_threshold_bytes must be greater than zero."
  }
}

variable "tags" {
  description = "Tags applied to observability resources."
  type        = map(string)
  default     = {}
}