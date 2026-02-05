variable "waf_name" {
  type        = string
  description = "Name of the WAF Web ACL"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "production"
}
