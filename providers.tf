terraform {
  required_version = "~> 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.12"
    }
  }
  cloud {
    organization = "kynetixx"
    workspaces {
      name = "ec2"
    }
  }
}

provider "aws" {
  region = var.region
}
