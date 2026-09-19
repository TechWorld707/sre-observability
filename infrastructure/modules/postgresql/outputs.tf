output "db_instance_id" {
  description = "Identifier of the PostgreSQL RDS instance."
  value       = aws_db_instance.postgresql.id
}

output "db_instance_arn" {
  description = "ARN of the PostgreSQL RDS instance."
  value       = aws_db_instance.postgresql.arn
}

output "db_instance_address" {
  description = "Private DNS address of the PostgreSQL RDS instance."
  value       = aws_db_instance.postgresql.address
}

output "db_instance_endpoint" {
  description = "PostgreSQL endpoint including its port."
  value       = aws_db_instance.postgresql.endpoint
}

output "db_instance_port" {
  description = "Port used by PostgreSQL."
  value       = aws_db_instance.postgresql.port
}

output "database_name" {
  description = "Name of the initial PostgreSQL database."
  value       = var.database_name
}

output "database_username" {
  description = "PostgreSQL administrator username."
  value       = var.database_username
}

output "database_url_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DATABASE_URL."
  value       = aws_secretsmanager_secret.database_url.arn
}

output "database_kms_key_arn" {
  description = "ARN of the KMS key encrypting database resources."
  value       = aws_kms_key.database.arn
}

output "postgresql_log_group_name" {
  description = "Name of the PostgreSQL CloudWatch log group."
  value       = aws_cloudwatch_log_group.postgresql.name
}

output "enhanced_monitoring_role_arn" {
  description = "ARN of the RDS Enhanced Monitoring role."
  value       = try(aws_iam_role.enhanced_monitoring[0].arn, null)
}