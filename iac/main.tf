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
  for_each    = var.apps
  source      = "./modules/static-site"
  bucket_name = each.value.bucket_name
}

module "cloudfront" {
  source = "./modules/cloudfront"

  web_acl_id     = "arn:aws:wafv2:us-east-1:354672111799:global/webacl/CreatedByCloudFront-ed845f24/9adf3acf-ba9f-4787-874c-7daa075f6690"
  hosted_zone_id = var.hosted_zone_id

  s3_buckets = {
    for app_name, app_config in var.apps :
    app_name => {
      id          = module.static_site[app_name].bucket_id
      domain_name = module.static_site[app_name].bucket_regional_domain_name
      arn         = module.static_site[app_name].bucket_arn
      sub_domain  = app_config.sub_domain
    }
  }

  providers = {
    aws       = aws
    aws.east1 = aws.east1
  }
}