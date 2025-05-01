resource "aws_vpc" "vpc-1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "accountant"
  }
}

resource "aws_subnet" "public_subnet-1" {
  vpc_id                  = aws_vpc.vpc-1.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Kalki"
  }
}

resource "aws_subnet" "public_subnet-2" {
  vpc_id                  = aws_vpc.vpc-1.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "Kalki-1b"
  }
}

#create internet gateway
resource "aws_internet_gateway" "igw-1" {
  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = "Kalki-IGW"
  }
}

# Create route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-1.id
  }
  tags = {
    Name = "Kalki-RT"
  }
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "public_subnet_association-1" {
  subnet_id      = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_subnet_association-2" {
  subnet_id      = aws_subnet.public_subnet-2.id
  route_table_id = aws_route_table.public_route_table.id
}



# Create security group for the public subnet
resource "aws_security_group" "sg-1" {
  vpc_id = aws_vpc.vpc-1.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Kalki-SG"
  }
}

##creating security group in a different way
resource "aws_security_group" "sg-2" {
  vpc_id = aws_vpc.vpc-1.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "Kalki-SG-2"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.sg-2.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH access"
}

resource "aws_security_group_rule" "allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.sg-2.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP access"
}
