resource "aws_lb_target_group" "public_tg" {
  name     = "public-tg"
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

resource "aws_lb_target_group_attachment" "proxy_1" {
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = aws_instance.proxy_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "proxy_2" {
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = aws_instance.proxy_2.id
  port             = 80
}

resource "aws_lb" "public_alb" {
  name               = "public-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_public_alb.id]
  subnets            = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
  internal           = false

  tags = {
    Name = "public-alb"
  }
}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}

