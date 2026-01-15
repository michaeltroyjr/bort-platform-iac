terraform {
  backend "s3" {
    bucket         = "state-file-iac"
    key            = "static-site/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}