######## VARIABLE TEMPLATE ##########
# variable "name_labbel" {
#   type = value
#   description = "string"
#   default = value
#   sensitive = true | false
# }

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
  sensitive   = true
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames"
  default     = true
}

variable "vpc_cidr_block" {
  type        = string
  description = "the CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnet1_cidr_block" {
  type        = string
  description = "the CIDR block for the public subnet 1"
  default     = "10.0.0.0/24"
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Map a public IP address for the Subnet instances"
  default     = true
}

variable "instance_type" {
  type        = string
  description = "the type for the ec2 instance"
  default     = "t2.micro"
}

variable "company" {
  type        = string
  description = "the company name for resource tagging"
  default     = "GoatLabs"
}

variable "project" {
  type        = string
  description = "the project name for resource tagging"
}

variable "billing_code" {
  type        = string
  description = "the billing code for resource tagging"
}
