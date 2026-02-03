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
  alias  = "east1"
  region = "us-east-1"
}

module "static_site" {
  source      = "./modules/static-site"
  bucket_name = var.bucket_name
}

module "cloudfront" {
  source                = "./modules/cloudfront"
  s3_bucket_domain_name = module.static_site.bucket_regional_domain_name
  hosted_zone_id        = var.hosted_zone_id


  providers = {
    aws       = aws
    aws.east1 = aws.east1
  }
}

data "aws_iam_policy_document" "s3_cloudfront_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.static_site.bucket_arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [module.cloudfront.distribution_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = module.static_site.bucket_id
  policy = data.aws_iam_policy_document.s3_cloudfront_policy.json
}