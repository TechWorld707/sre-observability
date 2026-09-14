variable "name" {
  description = "Name prefix applied to security-group resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The name must not be empty."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created."
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "The vpc_id must be a valid AWS VPC ID."
  }
}

variable "frontend_port" {
  description = "Port exposed by the Nginx frontend container."
  type        = number
  default     = 80

  validation {
    condition     = var.frontend_port >= 1 && var.frontend_port <= 65535
    error_message = "The frontend port must be between 1 and 65535."
  }
}

variable "backend_port" {
  description = "Port exposed by the FastAPI backend container."
  type        = number
  default     = 8000

  validation {
    condition     = var.backend_port >= 1 && var.backend_port <= 65535
    error_message = "The backend port must be between 1 and 65535."
  }
}

variable "database_port" {
  description = "Port used by PostgreSQL."
  type        = number
  default     = 5432

  validation {
    condition     = var.database_port >= 1 && var.database_port <= 65535
    error_message = "The database port must be between 1 and 65535."
  }
}

variable "tags" {
  description = "Tags applied to security-group resources."
  type        = map(string)
  default     = {}
}