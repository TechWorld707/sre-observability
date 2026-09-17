output "namespace_id" {
  description = "ID of the Service Connect namespace."
  value       = aws_service_discovery_http_namespace.application.id
}

output "namespace_arn" {
  description = "ARN of the Service Connect namespace."
  value       = aws_service_discovery_http_namespace.application.arn
}

output "namespace_name" {
  description = "Name of the Service Connect namespace."
  value       = aws_service_discovery_http_namespace.application.name
}