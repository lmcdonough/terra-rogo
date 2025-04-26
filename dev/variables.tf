variable "aws_access_key" {
  description = "the aws access key"
  type        = string
}

variable "aws_secret_key" {
  description = "the aws secret key"
  type        = string
}

variable "aws_region" {
  description = "the aws region"
  type        = string
  default     = "us-east-1"
}
