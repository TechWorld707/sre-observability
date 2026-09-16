output "cluster_id" {
  description = "ID of the ECS cluster."
  value       = aws_ecs_cluster.application.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster."
  value       = aws_ecs_cluster.application.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.application.name
}

output "service_id" {
  description = "ID of the frontend ECS service."
  value       = aws_ecs_service.frontend.id
}

output "service_name" {
  description = "Name of the frontend ECS service."
  value       = aws_ecs_service.frontend.name
}

output "task_definition_arn" {
  description = "ARN of the active frontend task definition."
  value       = aws_ecs_task_definition.frontend.arn
}

output "task_execution_role_arn" {
  description = "ARN of the frontend ECS task execution role."
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the frontend application task role."
  value       = aws_iam_role.task.arn
}

output "log_group_name" {
  description = "Name of the frontend container CloudWatch log group."
  value       = aws_cloudwatch_log_group.frontend.name
}

output "ecs_exec_log_group_name" {
  description = "Name of the ECS Exec CloudWatch log group."
  value       = aws_cloudwatch_log_group.ecs_exec.name
}

output "logs_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt frontend logs."
  value       = aws_kms_key.frontend_logs.arn
}