variable "web_acl_id" {
  type        = string
  description = "ID for Web ACL"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID"
}

variable "app_name" {
  type        = string
  description = "Name of the app"
}

variable "sub_domain" {
  type        = string
  description = "Subdomain for the app"
}

variable "bucket_id" {
  type        = string
  description = "S3 bucket ID"
}

variable "bucket_domain_name" {
  type        = string
  description = "S3 bucket regional domain name"
}

variable "bucket_arn" {
  type        = string
  description = "S3 bucket ARN"
}


variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for certificate DNS validation"
}