variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "aws_region" {
  type        = string
  description = "aws region"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for certificate DNS validation"
}