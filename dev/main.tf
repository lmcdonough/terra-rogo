# Providers
provider "aws" {
  access_key = "ACCESS_KEY"
  secret_key = "SECRET_KEY"
  region     = "us-east-1"
}

# Data
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linus-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Resources

# Networking
resource " aws_vpc" "app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
}

resource "aws_subnet" "public_subnet1" {
  cidr_block              = "10.0.0.0/24"
  vpc_id                  = aws_vpc.app.id
  map_public_ip_on_launch = true # makes it public by creating a route to the igw and assigning an elastic ip on launch
}

# Routing
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"                 # route all traffic (0.0.0.0/0) from the public subnet to the igw
    gateway_id = aws_internet_gateway.app.id #  route all traffic to the igw
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "app_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.app.id
}
# Security Groups
# Nginx security group
resource "aws_security_group" "nginx" {
  name   = "nginx_sg"     # give the security group a name
  vpc_id = aws_vpc.app.id # associate the security group with the vpc

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Intstances
resource "aws_instance" "nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  subnet_id              = aws_subnet.public_subnet1.id
  user_data              = <<EOF
  #! /bin/bash
  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start
  sudo rm /usr/share/nginx/html/index.html
  echo '<html><head><title>Terraform Demo</title></head><body><h1>Terraform Demo</h1><p>Welcome to my website!</p></body></html>' | sudo tee /usr/share/nginx/html/index.html"
  EOF
}
