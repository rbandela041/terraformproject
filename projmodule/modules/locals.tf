locals {
  env       = terraform.workspace
  vpc_name  = lower(var.vpc_name)
  dynamo_db = lower(var.dynamo_db)
  s3_bucket = lower(var.s3_bucket)
}

