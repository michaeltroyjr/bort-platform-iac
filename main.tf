terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "static_site" {
  source      = "./modules/static_site"
  bucket_name = var.bucket_name
}

module "cloudfront" {
  source                = "./modules/cloudfront"
  s3_bucket_domain_name = module.static_site.bucket_id
}