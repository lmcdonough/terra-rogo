#############################################################################
# Data Sources
#############################################################################

# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

############################################################################
# Resources
############################################################################

### Networking ###

# VPC
module "app" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"
  cidr    = var.vpc_cidr_block

  azs            = slice(data.aws_availability_zones.available.names, 0, var.vpc_public_subnet_count)
  public_subnets = [for subnet in range(var.vpc_public_subnet_count) : cidrsubnet(var.vpc_cidr_block, 8, subnet)]

  enable_nat_gateway      = false
  enable_vpn_gateway      = false
  enable_dns_hostnames    = var.enable_dns_hostnames
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags                    = merge(local.common_tags, { Name = "${local.naming_prefix}-vpc" })

}

### Security Groups ###

# Nginx security group
resource "aws_security_group" "nginx_sg" {
  name   = "nginx_sg"        # give the security group a name
  vpc_id = module.app.vpc_id # associate the security group with the vpc

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block] # allow access from only hosts in the VPC
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

# ALB security group
resource "aws_security_group" "alb_sg" {
  name   = "nginx_alb_sg"    # give the security group a name
  vpc_id = module.app.vpc_id # associate the security group with the vpc

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block] # allow access from only hosts in the VPC
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}
