terraform {
  backend "s3" {
    bucket  = "state-file-iac"
    key     = "envs/prod/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}