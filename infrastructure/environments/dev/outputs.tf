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

output "alb_security_group_id" {
  description = "ID of the Application Load Balancer security group."
  value       = module.security.alb_security_group_id
}

output "frontend_security_group_id" {
  description = "ID of the frontend security group."
  value       = module.security.frontend_security_group_id
}

output "backend_security_group_id" {
  description = "ID of the backend security group."
  value       = module.security.backend_security_group_id
}

output "database_security_group_id" {
  description = "ID of the PostgreSQL database security group."
  value       = module.security.database_security_group_id
}

output "load_balancer_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = module.alb.load_balancer_dns_name
}

output "load_balancer_arn_suffix" {
  description = "ARN suffix used for ALB CloudWatch metrics."
  value       = module.alb.load_balancer_arn_suffix
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group."
  value       = module.alb.frontend_target_group_arn
}

output "frontend_target_group_arn_suffix" {
  description = "ARN suffix used for target-group CloudWatch metrics."
  value       = module.alb.frontend_target_group_arn_suffix
}

output "frontend_ecs_cluster_name" {
  description = "Name of the ECS cluster hosting the frontend service."
  value       = module.frontend_ecs.cluster_name
}

output "frontend_ecs_cluster_arn" {
  description = "ARN of the ECS cluster hosting the frontend service."
  value       = module.frontend_ecs.cluster_arn
}

output "frontend_ecs_service_name" {
  description = "Name of the frontend ECS service."
  value       = module.frontend_ecs.service_name
}

output "frontend_task_definition_arn" {
  description = "ARN of the frontend ECS task definition."
  value       = module.frontend_ecs.task_definition_arn
}

output "frontend_log_group_name" {
  description = "Name of the frontend container CloudWatch log group."
  value       = module.frontend_ecs.log_group_name
}

output "frontend_ecs_exec_log_group_name" {
  description = "Name of the frontend ECS Exec CloudWatch log group."
  value       = module.frontend_ecs.ecs_exec_log_group_name
}