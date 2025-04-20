# terraform block with local backend
terraform {

  # terraform version
  required_version = ">= 1.5.7"

  # required providers config
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.95.0"
    }
  }
  # backend config
  backend "local" {
    path = "terraform.tfstate"
  }
}
