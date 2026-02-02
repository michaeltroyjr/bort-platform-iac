resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  default_root_object = "index.html"

  aliases = [
    "supreme-marines.bortplatforms.com"
  ]

  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3Origin"
  }

  default_cache_behavior {
    target_origin_id       = "S3Origin"
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
}

resource "aws_acm_certificate" "cf_cert" {
  domain_name       = "supreme-marines.bortplatforms.com"
  validation_method = "DNS"

  subject_alternative_names = [
    "bortplatforms.com",
    "www.bortplatforms.com"
  ]
}