resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.vpc_name
    env  = var.env
  }
}

resource "aws_internet_gateway" "vpc1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "${local.vpc_name}-igw"
    env  = var.env
  }
}
