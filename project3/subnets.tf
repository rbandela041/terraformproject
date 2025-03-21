resource "aws_subnet" "public-subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs, count.index)

  tags = {
    Name = "${local.vpc_name}-public-subnet-${count.index}"
    env  = var.env
  }
}

resource "aws_subnet" "private-subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs, count.index)

  tags = {
    Name = "${local.vpc_name}-private-subnet-${count.index}"
    env  = var.env
  }
}

