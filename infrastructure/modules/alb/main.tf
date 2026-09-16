locals {
  common_tags = merge(
    var.tags,
    {
      Module = "alb"
    }
  )
}

resource "aws_lb" "frontend" {
  #checkov:skip=CKV_AWS_91: ALB access logging will be enabled when the centralized logging bucket is added.

  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.security_group_id]
  subnets         = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  drop_invalid_header_fields = true
  enable_http2               = true
  idle_timeout               = var.idle_timeout_seconds
  desync_mitigation_mode     = "strictest"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-alb"
      Tier = "load-balancer"
    }
  )
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.name}-frontend"
  port        = var.frontend_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-frontend"
      Tier = "frontend"
    }
  )
}

resource "aws_lb_listener" "http_forward" {
  #checkov:skip=CKV_AWS_2: Development supports HTTP until an ACM certificate and domain are configured.

  count = var.certificate_arn == null ? 1 : 0

  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  count = var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.frontend.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = var.certificate_arn
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}