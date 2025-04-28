###################################################################
# DATA SOURCES
###################################################################

# AWS IAM POLICY DOCUMENT
data "aws_iam_policy_document" "allow_alb_logging" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.alb_account.arn}"]
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
  bucket        = local.s3_bucket_name
  force_destroy = true
  tags          = local.common_tags
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
        "AWS": "${data.aws_elb_service_account.alb_account.arn}"
    },
    "Action": "s3:PutObject",
    "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
    },
    "Action": "s3:PutObject",
    "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
    "Condition": {
      "StringEquals": {
        "s3:x-amz-acl": "bucket-owner-full-control"
      }
    }
    }]
  }
POLICY
}

# AWS S3 Object (the object in the bucket)
resource "aws_s3_object" "website" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/website/indext.html"
  source = "./website/index.html"
  tags   = local.common_tags

}

# AWS S3 Object (an image in the bucket)
resource "aws_s3_object" "graphic" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/website/graphic.png"
  source = "./website/graphic.png"
  tags   = local.common_tags
}

# AWS S3 BUCKET ACL (grant the load balancer principal access to the bucket)
resource "aws_s3_bucket_acl" "web_bucket" {
  depends_on = [aws_iam_instance_profile.nginx_profile]
  bucket     = aws_s3_bucket.web_bucket.id
  acl        = "private"
}
