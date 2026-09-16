data "aws_availability_zones" "available" {
  state = "available"
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

module "frontend_ecs" {
  source = "../../modules/frontend-ecs"

  name = local.name

  private_subnet_ids = module.network.private_application_subnet_ids
  security_group_id  = module.security.frontend_security_group_id
  target_group_arn   = module.alb.frontend_target_group_arn

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