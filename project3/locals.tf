locals {
  vpc_name  = lower(var.vpc_name)
  env       = lower(var.env)
  dynamo_db = lower(var.dynamo_db)
  s3_bucket = lower(var.s3_bucket)
}
