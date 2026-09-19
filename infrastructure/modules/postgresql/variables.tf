variable "name" {
  description = "Name prefix used for PostgreSQL resources."
  type        = string

  validation {
    condition = (
      length(trimspace(var.name)) > 0 &&
      length(var.name) <= 50
    )
    error_message = "The name must contain between 1 and 50 characters."
  }
}

variable "database_subnet_ids" {
  description = "Isolated subnet IDs used by the RDS subnet group."
  type        = list(string)

  validation {
    condition = (
      length(var.database_subnet_ids) >= 2 &&
      alltrue([
        for subnet_id in var.database_subnet_ids :
        can(regex("^subnet-[0-9a-f]+$", subnet_id))
      ])
    )
    error_message = "Provide at least two valid isolated database subnet IDs."
  }
}

variable "security_group_id" {
  description = "Security group attached to the PostgreSQL instance."
  type        = string

  validation {
    condition     = can(regex("^sg-[0-9a-f]+$", var.security_group_id))
    error_message = "The security_group_id must be a valid AWS security group ID."
  }
}

variable "database_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "minishop"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.database_name))
    error_message = "The database name must begin with a letter and contain only letters, numbers and underscores."
  }
}

variable "database_username" {
  description = "PostgreSQL administrator username."
  type        = string
  default     = "minishop_admin"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.database_username))
    error_message = "The database username must begin with a letter and contain only letters, numbers and underscores."
  }
}

variable "engine_version" {
  description = "PostgreSQL major engine version."
  type        = string
  default     = "17"
}

variable "parameter_group_family" {
  description = "PostgreSQL parameter group family."
  type        = string
  default     = "postgres17"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage_gib" {
  description = "Initial allocated PostgreSQL storage in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage_gib >= 20
    error_message = "PostgreSQL allocated storage must be at least 20 GiB."
  }
}

variable "max_allocated_storage_gib" {
  description = "Maximum storage autoscaling limit in GiB."
  type        = number
  default     = 100

  validation {
    condition     = var.max_allocated_storage_gib >= 20
    error_message = "Maximum allocated storage must be at least 20 GiB."
  }
}

variable "multi_az" {
  description = "Whether RDS Multi-AZ deployment is enabled."
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days automated database backups are retained."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1
    error_message = "Database backups must be retained for at least seven days."
  }
}

variable "deletion_protection" {
  description = "Whether RDS deletion protection is enabled."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether the final snapshot is skipped during deletion."
  type        = bool
  default     = true
}

variable "monitoring_interval_seconds" {
  description = "Enhanced Monitoring collection interval in seconds."
  type        = number
  default     = 60

  validation {
    condition = contains(
      [0, 1, 5, 10, 15, 30, 60],
      var.monitoring_interval_seconds
    )
    error_message = "Monitoring interval must be 0, 1, 5, 10, 15, 30 or 60 seconds."
  }
}

variable "performance_insights_enabled" {
  description = "Whether RDS Performance Insights is enabled."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days PostgreSQL logs are retained in CloudWatch."
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 365
    error_message = "PostgreSQL logs must be retained for at least 365 days."
  }
}

variable "secret_recovery_window_days" {
  description = "Secrets Manager recovery window used when deleting the database secret."
  type        = number
  default     = 7

  validation {
    condition = (
      var.secret_recovery_window_days == 0 ||
      (
        var.secret_recovery_window_days >= 7 &&
        var.secret_recovery_window_days <= 30
      )
    )
    error_message = "The secret recovery window must be zero or between 7 and 30 days."
  }
}

variable "tags" {
  description = "Tags applied to PostgreSQL resources."
  type        = map(string)
  default     = {}
}