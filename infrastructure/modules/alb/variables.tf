variable "name" {
  description = "Name prefix used for Application Load Balancer resources."
  type        = string

  validation {
    condition = (
      length(trimspace(var.name)) > 0 &&
      length(var.name) <= 28
    )
    error_message = "The name must contain 1 to 28 characters."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the target group will be created."
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "The vpc_id must be a valid AWS VPC ID."
  }
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the internet-facing ALB."
  type        = list(string)

  validation {
    condition = (
      length(var.public_subnet_ids) >= 2 &&
      alltrue([
        for subnet_id in var.public_subnet_ids :
        can(regex("^subnet-[0-9a-f]+$", subnet_id))
      ])
    )
    error_message = "Provide at least two valid public subnet IDs."
  }
}

variable "security_group_id" {
  description = "ID of the security group attached to the ALB."
  type        = string

  validation {
    condition     = can(regex("^sg-[0-9a-f]+$", var.security_group_id))
    error_message = "The security_group_id must be a valid AWS security group ID."
  }
}

variable "frontend_port" {
  description = "Port exposed by the Nginx frontend."
  type        = number
  default     = 80

  validation {
    condition     = var.frontend_port >= 1 && var.frontend_port <= 65535
    error_message = "The frontend port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "HTTP path used to check frontend health."
  type        = string
  default     = "/healthz"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "The health-check path must begin with a forward slash."
  }
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN used by the HTTPS listener."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.certificate_arn == null ||
      can(regex("^arn:aws[a-zA-Z-]*:acm:", var.certificate_arn))
    )
    error_message = "certificate_arn must be null or a valid ACM certificate ARN."
  }
}

variable "enable_deletion_protection" {
  description = "Whether deletion protection is enabled for the ALB."
  type        = bool
  default     = false
}

variable "idle_timeout_seconds" {
  description = "ALB idle timeout in seconds."
  type        = number
  default     = 60

  validation {
    condition = (
      var.idle_timeout_seconds >= 1 &&
      var.idle_timeout_seconds <= 4000
    )
    error_message = "The idle timeout must be between 1 and 4000 seconds."
  }
}

variable "tags" {
  description = "Tags applied to ALB resources."
  type        = map(string)
  default     = {}
}