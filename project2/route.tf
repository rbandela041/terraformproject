resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1.id
  }

  tags = {
    Name = "${local.vpc_name}-public-rt"
    env  = var.env
  }
}

resource "aws_route_table_association" "public-rt-assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public-subnets[*].id, count.index)
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "${local.vpc_name}-private-rt"
    env  = var.env
  }
}

resource "aws_route_table_association" "private-rt-assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private-subnets[*].id, count.index)
  route_table_id = aws_route_table.privatert.id
}
