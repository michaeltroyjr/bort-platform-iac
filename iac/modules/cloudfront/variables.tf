variable "web_acl_id" {
  type        = string
  description = "ID for Web ACL"
}


variable "s3_buckets" {
  type        = map
  description = "s3 buckets"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for certificate DNS validation"
}