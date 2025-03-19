resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.subnet_cidr1
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "${var.vpc_name}-public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.subnet_cidr2
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "${var.vpc_name}-public-subnet-2"
  }
}
