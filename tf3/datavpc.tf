data "aws_vpc" "spiderman" {
    id = "vpc-08464753686b404a0"
}

resource "aws_internet_gateway" "igw-1" {
  vpc_id = data.aws_vpc.spiderman.id

  tags = {
    Name = "spiderman-IGW"
  }
}
