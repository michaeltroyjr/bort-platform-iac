terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "state-file-iac"
    key     = "static-site/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

provider "aws" {
  region  = "us-east-2"
  profile = "terraform"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "bort-supreme-marines-3"
}