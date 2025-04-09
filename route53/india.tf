resource "aws_vpc" "default-india" {
  provider             = aws.india
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.vpc_name}"
    Owner       = "Rahul Bandela"
    environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "default-india" {
  provider = aws.india
  vpc_id   = aws_vpc.default-india.id
  tags = {
    Name = "${var.IGW_name}"
  }
}

resource "aws_subnet" "subnet1-public-india" {
  provider          = aws.india
  vpc_id            = aws_vpc.default-india.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = "ap-south-1a"

  tags = {
    Name = "${var.public_subnet1_name}"
  }
}

resource "aws_subnet" "subnet2-public-india" {
  provider          = aws.india
  vpc_id            = aws_vpc.default-india.id
  cidr_block        = var.public_subnet2_cidr
  availability_zone = "ap-south-1b"

  tags = {
    Name = "${var.public_subnet2_name}"
  }
}

resource "aws_subnet" "subnet3-public-india" {
  provider          = aws.india
  vpc_id            = aws_vpc.default-india.id
  cidr_block        = var.public_subnet3_cidr
  availability_zone = "ap-south-1c"

  tags = {
    Name = "${var.public_subnet3_name}"
  }

}


resource "aws_route_table" "terraform-public-india" {
  provider = aws.india
  vpc_id   = aws_vpc.default-india.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default-india.id
  }
  tags = {
    Name = "${var.Main_Routing_Table}"
  }
}

resource "aws_route_table_association" "terraform-public1-india" {
  provider       = aws.india
  subnet_id      = aws_subnet.subnet1-public-india.id
  route_table_id = aws_route_table.terraform-public-india.id
}

resource "aws_route_table_association" "terraform-public2-india" {
  provider       = aws.india
  subnet_id      = aws_subnet.subnet2-public-india.id
  route_table_id = aws_route_table.terraform-public-india.id
}

resource "aws_route_table_association" "terraform-public3-india" {
  provider       = aws.india
  subnet_id      = aws_subnet.subnet3-public-india.id
  route_table_id = aws_route_table.terraform-public-india.id
}

resource "aws_security_group" "allow_all-india" {
  provider    = aws.india
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.default-india.id
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

resource "aws_instance" "web-1-india" {
  provider                    = aws.india
  ami                         = "ami-02eb7a4783e7e9317"
  availability_zone           = "ap-south-1a"
  instance_type               = "t2.micro"
  key_name                    = "mykey"
  subnet_id                   = aws_subnet.subnet1-public-india.id
  vpc_security_group_ids      = ["${aws_security_group.allow_all-india.id}"]
  associate_public_ip_address = true
  tags = {
    Name       = "India-Server-1"
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
	echo "<h1>India-Server-1</h1>" | sudo tee -a /var/www/html/index.nginx-debian.html
	EOF
}

