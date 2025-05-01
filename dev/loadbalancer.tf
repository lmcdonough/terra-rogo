
###############################################################
# DATA SOURCES
###############################################################

# AWS ELB Service Account ARN
data "aws_elb_service_account" "alb_account" { # gets the ARN of the AWS ELB service account
  # depends_on = [module.web_app_s3]

}

###############################################################
# RESOURCES
###############################################################


# AWS ALB (application load balancer)
resource "aws_lb" "nginx" {
  name                       = "nanny-goat-labs-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = module.web_app_s3.public_subnets # public subnets from the module
  depends_on                 = [module.web_app_s3]              # wait for the s3 bucket to be created
  enable_deletion_protection = false                            # allows terraform to destroy the resource (for testing)
  access_logs {                                                 # logs to s3 bucket
    bucket  = module.web_app_s3.web_bucket.id                   # bucket name
    prefix  = "alb-logs"                                        # prefix for the logs
    enabled = true
  }
  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-alb" })
}

# aws_lb_target_group
resource "aws_lb_target_group" "nginx" { # target group for the load balancer
  name     = "nanny-goat-labs-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.app.vpc_id # VPC ID
  tags     = merge(local.common_tags, { Name = "${local.naming_prefix}-alb-tg" })
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
  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-alb-listener" })
}

# aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "nginx" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.nginx.arn      # ARN of the target group
  target_id        = aws_instance.nginx[count.index].id # ID of the instance to be attached
  port             = 80
}
