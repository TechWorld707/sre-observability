output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.network.vpc_id
}

output "availability_zones" {
  description = "Availability Zones used by the environment."
  value       = module.network.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = module.network.public_subnet_ids
}

output "private_application_subnet_ids" {
  description = "IDs of private application subnets."
  value       = module.network.private_application_subnet_ids
}

output "isolated_database_subnet_ids" {
  description = "IDs of isolated database subnets."
  value       = module.network.isolated_database_subnet_ids
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways."
  value       = module.network.nat_gateway_ids
}

output "vpc_flow_log_group_name" {
  description = "CloudWatch log group used for VPC Flow Logs."
  value       = module.network.vpc_flow_log_group_name
}