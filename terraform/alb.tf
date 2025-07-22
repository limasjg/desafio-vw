resource "aws_lb" "app_lb" {
  name               = "alb-app-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  tags               = merge(local.common_tags, { Name = "alb-app-${var.env}" })
}

resource "aws_lb_target_group" "app_tg" {
  name        = "tg-app-${var.env}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path     = "/"
    matcher  = "200"
  }
  tags = merge(local.common_tags, { Name = "tg-app-${var.env}" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}