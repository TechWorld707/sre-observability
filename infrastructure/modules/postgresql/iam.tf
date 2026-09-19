data "aws_iam_policy_document" "enhanced_monitoring_assume_role" {
  statement {
    sid     = "AllowRDSMonitoring"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  count = var.monitoring_interval_seconds > 0 ? 1 : 0

  name               = "${var.name}-rds-monitoring"
  description        = "Allows RDS Enhanced Monitoring to publish operating system metrics."
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-rds-monitoring"
    }
  )
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.monitoring_interval_seconds > 0 ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}