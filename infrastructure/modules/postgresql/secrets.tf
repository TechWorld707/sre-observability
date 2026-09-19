resource "random_password" "database" {
  length  = 32
  special = true

  # RDS master passwords cannot contain forward slash, double quote,
  # at sign or spaces. URL encoding protects the remaining characters.
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "database_url" {
  #checkov:skip=CKV2_AWS_57: Automatic rotation requires a rotation Lambda and coordinated database credential update, which will be added in a dedicated rotation change.

  name                    = "${var.name}/database-url"
  description             = "SQLAlchemy PostgreSQL connection URL used by the MiniShop backend."
  kms_key_id              = aws_kms_key.database.arn
  recovery_window_in_days = var.secret_recovery_window_days

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-database-url"
    }
  )
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id = aws_secretsmanager_secret.database_url.id

  secret_string = format(
    "postgresql+psycopg2://%s:%s@%s:%s/%s",
    urlencode(var.database_username),
    urlencode(random_password.database.result),
    aws_db_instance.postgresql.address,
    aws_db_instance.postgresql.port,
    var.database_name
  )
}