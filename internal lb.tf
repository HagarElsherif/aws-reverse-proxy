resource "aws_lb_target_group" "internal_tg" {
  name     = "internal-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "backend_1" {
  target_group_arn = aws_lb_target_group.internal_tg.arn
  target_id        = aws_instance.backend_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "backend_2" {
  target_group_arn = aws_lb_target_group.internal_tg.arn
  target_id        = aws_instance.backend_2.id
  port             = 80
}

resource "aws_lb" "internal_alb" {
 
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_internal_alb.id]
  subnets            = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]

  tags = {
    Name = "internal-alb"
  }
}

resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_tg.arn
  }
}

