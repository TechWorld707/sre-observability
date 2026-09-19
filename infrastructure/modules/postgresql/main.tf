resource "aws_db_subnet_group" "postgresql" {
  name        = "${var.name}-postgres"
  description = "Isolated database subnets for MiniShop PostgreSQL."
  subnet_ids  = var.database_subnet_ids

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-postgres"
    }
  )
}

resource "aws_db_parameter_group" "postgresql" {
  name        = "${var.name}-${var.parameter_group_family}"
  family      = var.parameter_group_family
  description = "Security and logging parameters for MiniShop PostgreSQL."

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_connections"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_disconnections"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_min_duration_statement"
    value        = "1000"
    apply_method = "immediate"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-${var.parameter_group_family}"
    }
  )
}

resource "aws_cloudwatch_log_group" "postgresql" {
  name              = "/aws/rds/instance/${local.database_identifier}/postgresql"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.database.arn

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-postgresql"
    }
  )
}

resource "aws_db_instance" "postgresql" {
  #checkov:skip=CKV_AWS_157: Development uses a single-AZ database to control demonstration cost; production must enable Multi-AZ.
  #checkov:skip=CKV_AWS_293: Development disables deletion protection for controlled cost-safe teardown; production must enable it.

  identifier = local.database_identifier

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.database_username
  password = random_password.database.result
  port     = 5432

  allocated_storage     = var.allocated_storage_gib
  max_allocated_storage = var.max_allocated_storage_gib
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.database.arn

  db_subnet_group_name   = aws_db_subnet_group.postgresql.name
  parameter_group_name   = aws_db_parameter_group.postgresql.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible = false
  multi_az            = var.multi_az
  network_type        = "IPV4"

  backup_retention_period = var.backup_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  auto_minor_version_upgrade  = true
  allow_major_version_upgrade = false
  apply_immediately           = true

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.database_identifier}-final"
  delete_automated_backups  = var.skip_final_snapshot
  copy_tags_to_snapshot     = true

  iam_database_authentication_enabled = true

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? aws_kms_key.database.arn : null
  performance_insights_retention_period = var.performance_insights_enabled ? 7 : null

  monitoring_interval = var.monitoring_interval_seconds
  monitoring_role_arn = var.monitoring_interval_seconds > 0 ? aws_iam_role.enhanced_monitoring[0].arn : null

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  ca_cert_identifier = "rds-ca-rsa2048-g1"

  tags = merge(
    local.common_tags,
    {
      Name = local.database_identifier
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.postgresql,
    aws_iam_role_policy_attachment.enhanced_monitoring
  ]
}