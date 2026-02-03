variable "s3_bucket_domain_name" {
  type        = string
  description = "S3 bucket domain name"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for certificate DNS validation"
}