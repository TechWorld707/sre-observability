variable "name" {
  description = "Name prefix for network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used by the VPC."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones must be provided."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public ALB and NAT subnets."
  type        = list(string)
}

variable "private_application_subnet_cidrs" {
  description = "CIDR blocks for private ECS application subnets."
  type        = list(string)
}

variable "isolated_database_subnet_cidrs" {
  description = "CIDR blocks for isolated RDS database subnets."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether NAT gateways should be created."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway instead of one per Availability Zone."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Whether VPC Flow Logs should be enabled."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days to retain VPC Flow Logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}