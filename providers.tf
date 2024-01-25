terraform {
  required_version = "~>1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.12"
    }
  }
  backend "s3" {
    bucket         = "s3-tfstate-146"
    key            = "tfstate/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.region
}
