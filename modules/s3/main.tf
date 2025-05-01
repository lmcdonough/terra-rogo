###################################################################
# DATA SOURCES
###################################################################

# AWS IAM POLICY DOCUMENT
data "aws_iam_policy_document" "allow_alb_logging" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${var.elb_service_account_arn}"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.web_bucket.arn}/alb-logs/*"]
  }
}


###################################################################
# RESOURCES
###################################################################

# Aws S3 Bucket (the bucket itself)
resource "aws_s3_bucket" "web_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = var.common_tags
}

# AWS S3 Bucket Policy (policy for the bucket)
resource "aws_s3_bucket_policy" "web_bucket" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = <<POLICY
  {
    "Version":"2012-10-17",
    "Statement":[{
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.elb_service_account_arn}"
    },
    "Action": "s3:PutObject",
    "Resource": "arn:aws:s3:::${var.bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
    },
    "Action": "s3:PutObject",
    "Resource": "arn:aws:s3:::${var.bucket_name}/alb-logs/*",
    "Condition": {
      "StringEquals": {
        "s3:x-amz-acl": "bucket-owner-full-control"
      }
    }
    }]
  }
POLICY
}

# AWS IAM Role (role for the instances)
resource "aws_iam_role" "allow_nginx_s3" {
  name               = "${var.bucket_name}-allow-nginx-s3"
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
  tags               = var.common_tags
}


# AWS IAM Instance Profile (profile for the instances)
resource "aws_iam_instance_profile" "nginx_profile" {
  name = "${var.bucket_name}-nginx-profile"
  role = aws_iam_role.allow_nginx_s3.name
  tags = var.common_tags
}


# AWS IAM Role Policy (role policy for S3 access)
resource "aws_iam_role_policy" "allow_s3_all" {
  name   = "${var.bucket_name}-allow-s3-all"
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
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
  ]
}
EOF
}
