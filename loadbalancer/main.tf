# load balancer Main

resource "aws_lb" "auto_lb" {
  name               = "auto-lb-tf"
  load_balancer_type = "application"
  security_groups    = [var.public_sg]
  subnets            = var.public_subnet

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "auto_tg" {
  name     = "auto-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }

  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout             = var.lb_timeout
    interval            = var.lb_interval
  }
}

resource "aws_lb_listener" "auto_lb_listener" {
  load_balancer_arn = aws_lb.auto_lb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auto_tg.arn
  }
}


