output "service_id" {
  description = "ID of the backend ECS service."
  value       = aws_ecs_service.backend.id
}

output "service_name" {
  description = "Name of the backend ECS service."
  value       = aws_ecs_service.backend.name
}

output "task_definition_arn" {
  description = "ARN of the active backend task definition."
  value       = aws_ecs_task_definition.backend.arn
}

output "task_execution_role_arn" {
  description = "ARN of the backend ECS task execution role."
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the backend application task role."
  value       = aws_iam_role.task.arn
}

output "log_group_name" {
  description = "Name of the backend and Service Connect CloudWatch log group."
  value       = aws_cloudwatch_log_group.backend.name
}

output "logs_kms_key_arn" {
  description = "ARN of the KMS key encrypting backend logs."
  value       = aws_kms_key.backend_logs.arn
}

output "service_connect_discovery_name" {
  description = "Private Service Connect discovery name used by the frontend."
  value       = "backend"
}

output "service_connect_port" {
  description = "Private Service Connect port used by the frontend."
  value       = var.container_port
}