# bucket object
output "web_bucket" {
  value       = aws_s3_bucket.web_bucket
  description = "The S3 bucket object"
}

# instance profile object
output "instance_profile" {
  value       = aws_iam_instance_profile.nginx_profile
  description = "The IAM instance profile object"
}
