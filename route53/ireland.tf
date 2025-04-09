resource "aws_vpc" "default-ireland" {
  provider             = aws.ireland
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.vpc_name}"
    Owner       = "Rahul Bandela"
    environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "default-ireland" {
  provider = aws.ireland
  vpc_id   = aws_vpc.default-ireland.id
  tags = {
    Name = "${var.IGW_name}"
  }
}

resource "aws_subnet" "subnet1-public-ireland" {
  provider          = aws.ireland
  vpc_id            = aws_vpc.default-ireland.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name = "${var.public_subnet1_name}"
  }
}

resource "aws_subnet" "subnet2-public-ireland" {
  provider          = aws.ireland
  vpc_id            = aws_vpc.default-ireland.id
  cidr_block        = var.public_subnet2_cidr
  availability_zone = "eu-west-1b"

  tags = {
    Name = "${var.public_subnet2_name}"
  }
}

resource "aws_subnet" "subnet3-public-ireland" {
  provider          = aws.ireland
  vpc_id            = aws_vpc.default-ireland.id
  cidr_block        = var.public_subnet3_cidr
  availability_zone = "eu-west-1c"

  tags = {
    Name = "${var.public_subnet3_name}"
  }

}


resource "aws_route_table" "terraform-public-ireland" {
  provider = aws.ireland
  vpc_id   = aws_vpc.default-ireland.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default-ireland.id
  }
  tags = {
    Name = "${var.Main_Routing_Table}"
  }
}

resource "aws_route_table_association" "terraform-public1-ireland" {
  provider       = aws.ireland
  subnet_id      = aws_subnet.subnet1-public-ireland.id
  route_table_id = aws_route_table.terraform-public-ireland.id
}

resource "aws_route_table_association" "terraform-public2-ireland" {
  provider       = aws.ireland
  subnet_id      = aws_subnet.subnet2-public-ireland.id
  route_table_id = aws_route_table.terraform-public-ireland.id
}

resource "aws_route_table_association" "terraform-public3-ireland" {
  provider       = aws.ireland
  subnet_id      = aws_subnet.subnet3-public-ireland.id
  route_table_id = aws_route_table.terraform-public-ireland.id
}

resource "aws_security_group" "allow_all-ireland" {
  provider    = aws.ireland
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.default-ireland.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web-1-ireland" {
  provider                    = aws.ireland
  ami                         = "ami-00aa9d3df94c6c354"
  availability_zone           = "eu-west-1a"
  instance_type               = "t2.micro"
  key_name                    = "mykey"
  subnet_id                   = aws_subnet.subnet1-public-ireland.id
  vpc_security_group_ids      = ["${aws_security_group.allow_all-ireland.id}"]
  associate_public_ip_address = true
  tags = {
    Name       = "Ireland-Server-1"
    Env        = "Prod"
    Owner      = "Sree"
    CostCenter = "ABCD"
  }
  user_data = <<-EOF
	#!/bin/bash
  sudo apt-get update
	sudo apt-get install -y nginx
	sudo systemctl start nginx
	sudo systemctl enable nginx
	echo "<h1>Ireland-Server-1</h1>" | sudo tee -a /var/www/html/index.nginx-debian.html
	EOF
}

