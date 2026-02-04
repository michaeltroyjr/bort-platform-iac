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
  name                              = "s3-oac"
  description                       = "OAC for S3 buckets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [aws_acm_certificate_validation.cf_cert_validation]
  enabled             = true
  default_root_object = "index.html"
  web_acl_id          = var.web_acl_id

  aliases = concat(
    ["bortplatforms.com", "www.bortplatforms.com"],
    [for app_name in keys(var.s3_buckets) : "${app_name}.bortplatforms.com"]
  )

  # Dynamic origins
  dynamic "origin" {
    for_each = var.s3_buckets
    content {
      domain_name              = origin.value.domain_name
      origin_id                = "S3Origin-${origin.key}"
      origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    }
  }

  # Default behavior for root domain
  default_cache_behavior {
    target_origin_id       = "S3Origin-${keys(var.s3_buckets)[0]}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true
  }

  # Dynamic behaviors for each app
  dynamic "cache_behavior" {
    for_each = var.s3_buckets
    iterator = app
    content {
      path_pattern           = "${app.key}/*"
      target_origin_id       = "S3Origin-${app.key}"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      compress               = true
    }
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
}

resource "aws_acm_certificate" "cf_cert" {
  provider = aws.east1
  domain_name = "bortplatforms.com"
  subject_alternative_names = concat(
    ["www.bortplatforms.com"],
    [for app_name in keys(var.s3_buckets) : "${app_name}.bortplatforms.com"]
  )
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cf_cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cf_cert_validation" {
  provider               = aws.east1
  certificate_arn        = aws_acm_certificate.cf_cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

data "aws_iam_policy_document" "s3_cloudfront_policy" {
  version = "2008-10-17"

  statement {
    sid       = "AllowCloudFrontServicePrincipal"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::*/*"]

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
  for_each   = var.s3_buckets
  bucket     = each.value.id
  policy     = data.aws_iam_policy_document.s3_cloudfront_policy.json
}