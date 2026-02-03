aws_region  = "us-east-2"
bucket_name = "bort-supreme-marines-2"
hosted_zone_id = "Z008087630RMGCXEMVLJL"
sub_domain = "supreme-marines"

apps = {
  supreme_marines = {
    sub_domain = "supreme-marines"
    bucket_name = "bort-supreme-marines-2"
  }
}