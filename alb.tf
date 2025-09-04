module "alb_sg_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["alb", "sg"]
  context    = module.this.context
}

resource "aws_security_group" "alb" {
  name   = module.alb_sg_label.id
  vpc_id = local.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_allowed_cidr_blocks
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.alb_allowed_cidr_blocks
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpc_cidr_block]
  }

  tags = module.alb_sg_label.tags
}

module "alb_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["alb"]
  context    = module.this.context
}

resource "aws_lb" "main" {
  name                       = module.alb_label.id
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = local.public_subnets
  enable_deletion_protection = false

  tags = module.alb_label.tags
}

module "tg_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["tg"]
  context    = module.this.context
}

resource "aws_lb_target_group" "ip" {
  name                 = module.tg_label.id
  port                 = 80
  deregistration_delay = 30
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = local.vpc_id
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/healthz"
  }

  tags = module.tg_label.tags
}

resource "aws_lb_listener" "http" {
  count             = var.certificate_arn == null ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip.arn
  }

  tags = module.alb_label.tags
}

resource "aws_lb_listener" "https" {
  count             = var.certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip.arn
  }

  tags = module.alb_label.tags
}
