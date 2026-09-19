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

output "service_connect_namespace_id" {
  description = "ID of the private ECS Service Connect namespace."
  value       = module.service_connect.namespace_id
}

output "service_connect_namespace_arn" {
  description = "ARN of the private ECS Service Connect namespace."
  value       = module.service_connect.namespace_arn
}

output "service_connect_namespace_name" {
  description = "Name of the private ECS Service Connect namespace."
  value       = module.service_connect.namespace_name
}

output "postgresql_instance_id" {
  description = "Identifier of the PostgreSQL RDS instance."
  value       = module.postgresql.db_instance_id
}

output "postgresql_address" {
  description = "Private DNS address of the PostgreSQL RDS instance."
  value       = module.postgresql.db_instance_address
}

output "postgresql_port" {
  description = "Port used by PostgreSQL."
  value       = module.postgresql.db_instance_port
}

output "database_url_secret_arn" {
  description = "ARN of the secret containing the backend DATABASE_URL."
  value       = module.postgresql.database_url_secret_arn
}

output "database_kms_key_arn" {
  description = "ARN of the KMS key encrypting database resources."
  value       = module.postgresql.database_kms_key_arn
}

output "postgresql_log_group_name" {
  description = "Name of the PostgreSQL CloudWatch log group."
  value       = module.postgresql.postgresql_log_group_name
}

output "backend_ecs_service_name" {
  description = "Name of the backend ECS service."
  value       = module.backend_ecs.service_name
}

output "backend_task_definition_arn" {
  description = "ARN of the backend ECS task definition."
  value       = module.backend_ecs.task_definition_arn
}

output "backend_log_group_name" {
  description = "Name of the backend CloudWatch log group."
  value       = module.backend_ecs.log_group_name
}

output "backend_service_connect_name" {
  description = "Private Service Connect name used by the frontend."
  value       = module.backend_ecs.service_connect_discovery_name
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch operations dashboard."
  value       = module.observability.dashboard_name
}

output "cloudwatch_dashboard_url" {
  description = "AWS Console URL for the CloudWatch operations dashboard."
  value       = module.observability.dashboard_url
}

output "observability_alerts_topic_arn" {
  description = "ARN of the SNS topic used for operational alerts."
  value       = module.observability.alerts_topic_arn
}

output "cloudwatch_alarm_names" {
  description = "Names of the CloudWatch operational alarms."
  value       = module.observability.alarm_names
}