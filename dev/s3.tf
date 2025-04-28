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
        "AWS": "${data.aws_elb_service_account.root.arn}"
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
  bucket = aws_s3_bucket.bucket.bucket
  key    = "/website/graphic.png"
  source = "./website/graphic.png"
  tags   = local.common_tags
}


# AWS IAM Role (role for the instances)



# AWS IAM Role Policy (role policy for S3 access)



# AWS IAM Instance Profile (profile for the instances)



# AWS S3 Bucket Policy (grant the load balancer principal access to the bucket)




# AWS ELB Service Account (get the load balancer principal id)
