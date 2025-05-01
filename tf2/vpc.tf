data "aws_vpc" "ironman" {
    id = "vpc-0a396d0a9760beb01"
}

resource "aws_internet_gateway" "igw-1" {
  vpc_id = data.aws_vpc.ironman.id

  tags = {
    Name = "ironman-IGW"
  }
}
