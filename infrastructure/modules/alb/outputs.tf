output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.frontend.arn
}

output "load_balancer_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.frontend.dns_name
}

output "load_balancer_zone_id" {
  description = "Canonical hosted zone ID of the Application Load Balancer."
  value       = aws_lb.frontend.zone_id
}

output "load_balancer_arn_suffix" {
  description = "ARN suffix used for ALB CloudWatch metrics."
  value       = aws_lb.frontend.arn_suffix
}

output "frontend_target_group_arn" {
  description = "ARN of the frontend target group."
  value       = aws_lb_target_group.frontend.arn
}

output "frontend_target_group_arn_suffix" {
  description = "ARN suffix used for target-group CloudWatch metrics."
  value       = aws_lb_target_group.frontend.arn_suffix
}

output "http_listener_arn" {
  description = "ARN of the active HTTP listener."
  value = coalesce(
    try(aws_lb_listener.http_redirect[0].arn, null),
    try(aws_lb_listener.http_forward[0].arn, null)
  )
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener when an ACM certificate is configured."
  value       = try(aws_lb_listener.https[0].arn, null)
}