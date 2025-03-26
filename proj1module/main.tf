module "core" {
  source           = "./modules/core"

  vpc_name         = var.vpc_name
  vpc_cidr         = var.vpc_cidr
  subnet_cidr1     = var.subnet_cidr1
  subnet_cidr2     = var.subnet_cidr2
  ami              = var.ami
  instance_type    = var.instance_type
  key_name         = var.key_name
  env              = var.env
}

