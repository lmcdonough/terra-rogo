# the terraform block that specifies the provider configurations
terraform {
  required_version = "~> 1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.96.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

# The AWS Provider config
provider "aws" {} # all config options are env vars in the zshrc file

# The Random Provider config
provider "random" {
  # Configuration options
}
