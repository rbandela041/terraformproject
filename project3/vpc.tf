resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = join("-", [local.vpc_name, local.env])
    env  = local.env
  }
}

resource "aws_internet_gateway" "vpc1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = join("-", [local.vpc_name, local.env, "igw"])
    env  = local.env
  }
}
