variable "name" {
  description = "Name of the private ECS Service Connect namespace."
  type        = string

  validation {
    condition = (
      length(trimspace(var.name)) > 0 &&
      length(var.name) <= 1024
    )
    error_message = "The Service Connect namespace name must contain between 1 and 1024 characters."
  }
}

variable "description" {
  description = "Description of the Service Connect namespace."
  type        = string
  default     = "Private service discovery namespace for ECS workloads."
}

variable "tags" {
  description = "Tags applied to the Service Connect namespace."
  type        = map(string)
  default     = {}
}