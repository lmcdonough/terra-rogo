# aws_elb_service_account



# aws_lb
resource "aws_lb" "nginx" {
  name                       = "nanny-goat-labs-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  enable_deletion_protection = false # allows terraform to destroy the resource (for testing)
  tags                       = local.common_tags
}

# aws_lb_target_group
resource "aws_lb_target_group" "nginx" {
  name     = "nanny-goat-labs-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app.id
  tags     = local.common_tags
}

# aws_lb_listener
resource "aws_lb_listener" "nginx" {
  load_balancer_arn = aws_lb.nginx.arn # ARN of the load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn # ARN of the target group
  }
  tags = local.common_tags
}

# aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "nginx1" {
  target_group_arn = aws_lb_target_group.nginx.arn # ARN of the target group
  target_id        = aws_instance.nginx1.id        # ID of the instance to be attached
  port             = 80
}

resource "aws_lb_target_group_attachment" "nginx2" {
  target_group_arn = aws_lb_target_group.nginx.arn # ARN of the target group
  target_id        = aws_instance.nginx2.id        # ID of the instance to be attached
  port             = 80
}
