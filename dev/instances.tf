data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


# Instances
resource "aws_instance" "nginx" {
  count                  = var.instance_count
  ami                    = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]
  subnet_id              = aws_subnet.public_subnets[(count.index % var.vpc_public_subnet_count)].id
  user_data = templatefile("${path.module}/templates/startup_script.tpl", {
    s3_bucket_name = aws_s3_bucket.web_bucket.id
  })

  tags = local.common_tags
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
      "Resource": [
        "arn:aws:s3:::${local.s3_bucket_name}",
        "arn:aws:s3:::${local.s3_bucket_name}/*"
      ]
    }
  ]
}
EOF
}




