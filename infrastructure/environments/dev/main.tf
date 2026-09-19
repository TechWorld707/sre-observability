data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-id"
    values = var.availability_zone_ids
  }
}

locals {
  name         = "${var.project_name}-${var.environment}"
  network_name = "${var.network_name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    var.availability_zone_count
  )

  public_subnet_cidrs = [
    for index in range(var.availability_zone_count) :
    cidrsubnet(var.vpc_cidr, 8, index)
  ]

  private_application_subnet_cidrs = [
    for index in range(var.availability_zone_count) :
    cidrsubnet(var.vpc_cidr, 8, index + 10)
  ]

  isolated_database_subnet_cidrs = [
    for index in range(var.availability_zone_count) :
    cidrsubnet(var.vpc_cidr, 8, index + 20)
  ]
}

module "network" {
  source = "../../modules/network"

  name                             = local.network_name
  vpc_cidr                         = var.vpc_cidr
  availability_zones               = local.availability_zones
  public_subnet_cidrs              = local.public_subnet_cidrs
  private_application_subnet_cidrs = local.private_application_subnet_cidrs
  isolated_database_subnet_cidrs   = local.isolated_database_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_flow_logs        = var.enable_flow_logs
  flow_log_retention_days = var.flow_log_retention_days

  tags = local.common_tags
}

module "security" {
  source = "../../modules/security"

  name   = local.name
  vpc_id = module.network.vpc_id

  frontend_port = 80
  backend_port  = 8000
  database_port = 5432

  tags = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  name                 = local.name
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  security_group_id    = module.security.alb_security_group_id
  frontend_port        = 80
  health_check_path    = "/healthz"
  certificate_arn      = null
  idle_timeout_seconds = 60

  # Development must support controlled teardown.
  enable_deletion_protection = false

  tags = local.common_tags
}

module "service_connect" {
  source = "../../modules/service-connect"

  name        = "${local.name}-internal"
  description = "Private service discovery namespace for MiniShop ECS services."

  tags = local.common_tags
}

module "frontend_ecs" {
  source = "../../modules/frontend-ecs"

  name = local.name

  private_subnet_ids = module.network.private_application_subnet_ids
  security_group_id  = module.security.frontend_security_group_id
  target_group_arn   = module.alb.frontend_target_group_arn

  service_connect_namespace_arn = module.service_connect.namespace_arn

  container_image = var.frontend_container_image
  container_port  = 80
  desired_count   = var.frontend_desired_count

  task_cpu    = 256
  task_memory = 512

  log_retention_days     = var.frontend_log_retention_days
  enable_execute_command = true

  tags = local.common_tags

  depends_on = [
    module.alb
  ]
}

module "postgresql" {
  source = "../../modules/postgresql"

  name = local.name

  database_subnet_ids = module.network.isolated_database_subnet_ids
  security_group_id   = module.security.database_security_group_id

  database_name     = "minishop"
  database_username = "minishop_admin"

  engine_version         = "17"
  parameter_group_family = "postgres17"
  instance_class         = "db.t4g.micro"

  allocated_storage_gib     = 20
  max_allocated_storage_gib = 100

  multi_az              = false
  deletion_protection   = false
  skip_final_snapshot   = true
  backup_retention_days = 7

  monitoring_interval_seconds  = 60
  performance_insights_enabled = true
  log_retention_days           = 365
  secret_recovery_window_days  = 7

  tags = local.common_tags
}

module "backend_ecs" {
  source = "../../modules/backend-ecs"

  name = local.name

  cluster_arn        = module.frontend_ecs.cluster_arn
  private_subnet_ids = module.network.private_application_subnet_ids
  security_group_id  = module.security.backend_security_group_id

  service_connect_namespace_arn = module.service_connect.namespace_arn

  container_image = var.backend_container_image
  container_port  = 8000
  desired_count   = var.backend_desired_count

  task_cpu    = 256
  task_memory = 512

  database_url_secret_arn     = module.postgresql.database_url_secret_arn
  database_secret_kms_key_arn = module.postgresql.database_kms_key_arn

  log_retention_days     = var.backend_log_retention_days
  enable_execute_command = true

  tags = local.common_tags

  depends_on = [
    module.postgresql,
    module.service_connect
  ]
}