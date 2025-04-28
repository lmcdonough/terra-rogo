
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
resource "aws_iam_role" "allow_nginx_s3" {
  name               = "allow_nginx_s3"
  assume_role_policy = <<EOF
{ "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]}
  EOF
  tags               = local.common_tags
}


# AWS IAM Instance Profile (profile for the instances)
resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name
  tags = local.common_tags
}


# AWS IAM Role Policy (role policy for S3 access)
resource "aws_iam_role_policy" "allow_s3_all" {
  name   = "allow_s3_all"
  role   = aws_iam_role.allow_nginx_s3.name
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": 
      "arn:aws:s3:::${local.s3_bucket_name}",
      "arn:aws:s3:::${local.s3_bucket_name}/*"
    }
  ]}
  EOF
}




