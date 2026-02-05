terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.east1]
    }
  }
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-oac-${var.app_name}"
  description                       = "OAC for S3 bucket ${var.app_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_acm_certificate_validation.cf_cert_validation]
  enabled             = true
  default_root_object = "index.html"
  web_acl_id          = var.web_acl_id

  aliases = ["${var.sub_domain}.bortplatforms.com"]

  origin {
    domain_name              = var.bucket_domain_name
    origin_id                = "S3Origin-${var.app_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "S3Origin-${var.app_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cf_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "cloudfront-${var.app_name}"
    App  = var.app_name
  }
}

resource "aws_acm_certificate" "cf_cert" {
  provider          = aws.east1
  domain_name       = "${var.sub_domain}.bortplatforms.com"
  validation_method = "DNS"

  tags = {
    Name = "cert-${var.app_name}"
    App  = var.app_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  zone_id = var.hosted_zone_id
  name    = tolist(aws_acm_certificate.cf_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cf_cert.domain_validation_options)[0].resource_record_type
  ttl     = 300
  records = [tolist(aws_acm_certificate.cf_cert.domain_validation_options)[0].resource_record_value]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cf_cert_validation" {
  provider               = aws.east1
  certificate_arn        = aws_acm_certificate.cf_cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

data "aws_iam_policy_document" "s3_cloudfront_policy" {
  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  depends_on = [aws_cloudfront_distribution.s3_distribution]
  bucket     = var.bucket_id
  policy     = data.aws_iam_policy_document.s3_cloudfront_policy.json
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = var.hosted_zone_id
  name    = "${var.sub_domain}.bortplatforms.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront_alias_ipv6" {
  zone_id = var.hosted_zone_id
  name    = "${var.sub_domain}.bortplatforms.com"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

    evaluate_target_health = false
  }
}
