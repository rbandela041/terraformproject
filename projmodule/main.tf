module "infra" {
  source = "./modules"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  region               = var.region
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  dynamo_db            = var.dynamo_db
  s3_bucket            = var.s3_bucket
  test_role_arn        = var.test_role_arn
  qa_role_arn          = var.qa_role_arn
  db_username       = var.db_username
  db_password       = var.db_password
  db_engine         = var.db_engine
  db_instance_class = var.db_instance_class
  db_storage        = var.db_storage
}

