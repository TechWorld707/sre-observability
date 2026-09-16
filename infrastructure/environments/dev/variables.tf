variable "project_name" {
  description = "Name of the overall project."
  type        = string
  default     = "sre-observability"
}

variable "network_name" {
  description = "Name prefix used for the VPC and associated network resources."
  type        = string
  default     = "my-vpc"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region in which resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zone_count" {
  description = "Number of Availability Zones used by the network."
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zone_count >= 2
    error_message = "At least two Availability Zones must be used."
  }
}

variable "enable_nat_gateway" {
  description = "Whether NAT gateways should be created."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Whether one shared NAT gateway should be used to reduce development cost."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Whether VPC Flow Logs should be sent to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days that VPC Flow Logs are retained."
  type        = number
  default     = 365

  validation {
    condition     = var.flow_log_retention_days >= 365
    error_message = "flow_log_retention_days must be greater than or equal to 365."
  }
}

variable "tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)

  default = {
    Owner      = "TechWorld707"
    Repository = "sre-observability"
  }
}

variable "frontend_container_image" {
  description = "Immutable GHCR image used by the frontend ECS service."
  type        = string

  validation {
    condition = (
      startswith(var.frontend_container_image, "ghcr.io/") &&
      !endswith(var.frontend_container_image, ":latest")
    )
    error_message = "The frontend image must be a GHCR image with an immutable tag, not latest."
  }
}

variable "frontend_desired_count" {
  description = "Desired number of frontend ECS tasks."
  type        = number
  default     = 2

  validation {
    condition     = var.frontend_desired_count >= 2
    error_message = "At least two frontend tasks are required for multi-AZ availability."
  }
}

variable "frontend_log_retention_days" {
  description = "Number of days to retain frontend ECS logs."
  type        = number
  default     = 365

  validation {
    condition     = var.frontend_log_retention_days >= 365
    error_message = "Frontend ECS logs must be retained for at least 365 days."
  }
}