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
resource "aws_vpc" "app" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  tags                 = local.common_tags
}

# Internet Gateway
resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = local.common_tags
}

#### SUBNETS ###

# Public Subnet 1
resource "aws_subnet" "public_subnets" {
  count                   = var.vpc_public_subnet_count
  cidr_block              = var.vpc_public_subnets_cidr_block[count.index] # cidr block for the subnet using count.index
  vpc_id                  = aws_vpc.app.id
  availability_zone       = data.aws_availability_zones.available.names[count.index] # availability zone for the subnet using count.index
  map_public_ip_on_launch = var.map_public_ip_on_launch                              # makes it public by creating a route to the igw and assigning an elastic ip on launch
  tags                    = local.common_tags
}

### Routing ###

# Route table
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"                 # route all traffic (0.0.0.0/0) from the public subnet to the igw
    gateway_id = aws_internet_gateway.app.id #  route all traffic to the igw
  }
  tags = local.common_tags
}

# Route table association with public subnets
resource "aws_route_table_association" "app_public_subnets" {
  count          = var.vpc_public_subnet_count               # number of public subnets
  subnet_id      = aws_subnet.public_subnets[count.index].id # subnet id for the subnet using count.index
  route_table_id = aws_route_table.app.id
}

### Security Groups ###

# Nginx security group
resource "aws_security_group" "nginx_sg" {
  name   = "nginx_sg"     # give the security group a name
  vpc_id = aws_vpc.app.id # associate the security group with the vpc

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
  name   = "nginx_alb_sg" # give the security group a name
  vpc_id = aws_vpc.app.id # associate the security group with the vpc

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
