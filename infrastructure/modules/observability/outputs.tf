output "dashboard_name" {
  description = "Name of the CloudWatch operations dashboard."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_url" {
  description = "AWS Console URL for the CloudWatch operations dashboard."
  value = format(
    "https://%s.console.aws.amazon.com/cloudwatch/home?region=%s#dashboards:name=%s",
    data.aws_region.current.region,
    data.aws_region.current.region,
    aws_cloudwatch_dashboard.main.dashboard_name
  )
}

output "alerts_topic_arn" {
  description = "ARN of the SNS topic used for operational alarms."
  value       = aws_sns_topic.alerts.arn
}

output "alarm_names" {
  description = "Names of the CloudWatch operational alarms."
  value = {
    unhealthy_frontend_targets = aws_cloudwatch_metric_alarm.unhealthy_frontend_targets.alarm_name
    alb_5xx                    = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
    frontend_cpu               = aws_cloudwatch_metric_alarm.frontend_cpu.alarm_name
    frontend_memory            = aws_cloudwatch_metric_alarm.frontend_memory.alarm_name
    backend_cpu                = aws_cloudwatch_metric_alarm.backend_cpu.alarm_name
    backend_memory             = aws_cloudwatch_metric_alarm.backend_memory.alarm_name
    database_cpu               = aws_cloudwatch_metric_alarm.database_cpu.alarm_name
    database_free_storage      = aws_cloudwatch_metric_alarm.database_free_storage.alarm_name
  }
}