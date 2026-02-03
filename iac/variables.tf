variable "aws_region" {
  type        = string
  description = "aws region"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for certificate DNS validation"
}

variable "apps" {
  type        = map(any)
  description = "Each app deploys infra for that app"
}