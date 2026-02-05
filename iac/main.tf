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

# Shared WAF ACL for all CloudFront distributions
module "waf" {
  source      = "./modules/waf"
  waf_name    = "bort-platform-shared-waf"
  environment = "production"

  providers = {
    aws.east1 = aws.east1
  }
}

module "static_site" {
  for_each    = var.apps
  source      = "./modules/static-site"
  bucket_name = each.value.bucket_name
}

# CloudFront distribution for each app
module "cloudfront" {
  for_each = var.apps
  source   = "./modules/cloudfront"

  app_name           = each.key
  sub_domain         = each.value.sub_domain
  bucket_id          = module.static_site[each.key].bucket_id
  bucket_domain_name = module.static_site[each.key].bucket_regional_domain_name
  bucket_arn         = module.static_site[each.key].bucket_arn
  web_acl_id         = module.waf.web_acl_arn
  hosted_zone_id     = var.hosted_zone_id

  providers = {
    aws       = aws
    aws.east1 = aws.east1
  }
}