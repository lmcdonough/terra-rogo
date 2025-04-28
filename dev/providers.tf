# the terraform block that specifies the provider configurations
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
}

# the aws provider block confiiguration
provider "aws" {} # all config options are env vars in the zshrc file
