locals {
  common_tags = merge(
    var.tags,
    {
      Module = "security"
    }
  )
}

resource "aws_security_group" "alb" {
  #checkov:skip=CKV2_AWS_5: Checkov cannot resolve the cross-module attachment; this ID is attached to module.alb.
  name        = "${var.name}-alb"
  description = "Controls traffic to and from the public Application Load Balancer."
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-alb"
      Tier = "load-balancer"
    }
  )
}

resource "aws_security_group" "frontend" {
  #checkov:skip=CKV2_AWS_5: Security group is exported for attachment by the upcoming frontend ECS service.
  name        = "${var.name}-frontend"
  description = "Allows frontend traffic only from the Application Load Balancer."
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-frontend"
      Tier = "frontend"
    }
  )
}

resource "aws_security_group" "backend" {
  #checkov:skip=CKV2_AWS_5: Security group is exported for attachment by the upcoming backend ECS service.
  name        = "${var.name}-backend"
  description = "Allows backend traffic only from the frontend."
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-backend"
      Tier = "backend"
    }
  )
}

resource "aws_security_group" "database" {
  #checkov:skip=CKV2_AWS_5: Security group is exported for attachment by the upcoming PostgreSQL RDS module.
  name        = "${var.name}-database"
  description = "Allows PostgreSQL traffic only from the backend."
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-database"
      Tier = "database"
    }
  )
}

# HTTP is temporarily permitted for the public ALB.
# The ALB module will redirect HTTP requests to HTTPS.
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  #checkov:skip=CKV_AWS_260: Development permits public HTTP until an ACM certificate and domain are configured.

  security_group_id = aws_security_group.alb.id

  description = "Allow public HTTP traffic for HTTPS redirection."
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  description = "Allow public HTTPS traffic."
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_frontend" {
  security_group_id = aws_security_group.alb.id

  description                  = "Allow the ALB to reach the frontend."
  referenced_security_group_id = aws_security_group.frontend.id
  from_port                    = var.frontend_port
  to_port                      = var.frontend_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "frontend_from_alb" {
  #checkov:skip=CKV_AWS_260: Port 80 is restricted to the ALB security group and is not publicly accessible.
  security_group_id = aws_security_group.frontend.id

  description                  = "Allow frontend traffic only from the ALB."
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.frontend_port
  to_port                      = var.frontend_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "frontend_to_backend" {
  security_group_id = aws_security_group.frontend.id

  description                  = "Allow the frontend to reach the backend."
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = var.backend_port
  to_port                      = var.backend_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "frontend_https" {
  security_group_id = aws_security_group.frontend.id

  description = "Allow HTTPS for container downloads, logging and AWS APIs."
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "backend_from_frontend" {
  security_group_id = aws_security_group.backend.id

  description                  = "Allow backend traffic only from the frontend."
  referenced_security_group_id = aws_security_group.frontend.id
  from_port                    = var.backend_port
  to_port                      = var.backend_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_to_database" {
  security_group_id = aws_security_group.backend.id

  description                  = "Allow the backend to reach PostgreSQL."
  referenced_security_group_id = aws_security_group.database.id
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_https" {
  security_group_id = aws_security_group.backend.id

  description = "Allow HTTPS for container downloads, logging and AWS APIs."
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "database_from_backend" {
  security_group_id = aws_security_group.database.id

  description                  = "Allow PostgreSQL traffic only from the backend."
  referenced_security_group_id = aws_security_group.backend.id
  from_port                    = var.database_port
  to_port                      = var.database_port
  ip_protocol                  = "tcp"
}