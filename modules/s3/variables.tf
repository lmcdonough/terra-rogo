# bucket_name
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to be created"
}

# elb_service_account_arn
variable "elb_service_account_arn" {
  type        = string
  description = "ARN of the ELB service account"
}

# common_tags
variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources"
  default     = {}
}

