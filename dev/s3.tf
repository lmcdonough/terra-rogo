module "web_app_s3" {
  source                  = "../modules/s3"
  bucket_name             = local.s3_bucket_name
  elb_service_account_arn = data.aws_elb_service_account.alb_account.arn # the ARN of the ELB service account
  common_tags             = local.common_tags
}

# AWS S3 Object (the object in the bucket)
resource "aws_s3_object" "website_content" {
  for_each = local.website_content
  bucket   = module.web_app_s3.web_bucket.id # the bucket ID from the module
  key      = each.value
  source   = "${path.root}/${each.value}" # path.root is the root of the module
  tags     = local.common_tags

}
