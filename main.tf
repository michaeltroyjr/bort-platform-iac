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

provider "aws" {
  alias  = "east-1"
  region = "us-east-1"
}

module "static_site" {
  source      = "./modules/static-site"
  bucket_name = var.bucket_name
}

module "cloudfront" {
  source                = "./modules/cloudfront"
  s3_bucket_domain_name = module.static_site.bucket_regional_domain_name
}