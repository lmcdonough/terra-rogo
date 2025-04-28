
data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


# Instances
resource "aws_instance" "nginx1" {
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  subnet_id              = aws_subnet.public_subnet1.id
  user_data              = <<EOF
  #! /bin/bash
  #! /bin/bash
  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start
  sudo rm /usr/share/nginx/html/index.html
  echo '<html><head><title>Nanny Goat Labs</title></head><body><h1>Nanny Goat Labs I</h1><p>the original...</p></body></html>' > /usr/share/nginx/html/index.html
  EOF
  tags                   = local.common_tags
}

resource "aws_instance" "nginx2" {
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  subnet_id              = aws_subnet.public_subnet2.id
  user_data              = <<EOF
  #! /bin/bash
  sudo amazon-linux-extras install -y nginx1
  sudo service nginx start
  sudo rm /usr/share/nginx/html/index.html
  echo '<html><head><title>Nanny Goat Labs</title></head><body><h1>Nanny Goat Labs II</h1><p>this time it's personal...</p></body></html>' > /usr/share/nginx/html/index.html
  EOF
  tags                   = local.common_tags
}


# AWS IAM Role (role for the instances)



# AWS IAM Role Policy (role policy for S3 access)



# AWS IAM Instance Profile (profile for the instances)
