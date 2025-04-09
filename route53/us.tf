resource "aws_vpc" "default" {
  provider             = aws.eastus
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.vpc_name}"
    Owner       = "Rahul Bandela"
    environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "default" {
  provider = aws.eastus
  vpc_id   = aws_vpc.default.id
  tags = {
    Name = "${var.IGW_name}"
  }
}

resource "aws_subnet" "subnet1-public" {
  provider          = aws.eastus
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.public_subnet1_name}"
  }
}

resource "aws_subnet" "subnet2-public" {
  provider          = aws.eastus
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.public_subnet2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.public_subnet2_name}"
  }
}

resource "aws_subnet" "subnet3-public" {
  provider          = aws.eastus
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.public_subnet3_cidr
  availability_zone = "us-east-1c"

  tags = {
    Name = "${var.public_subnet3_name}"
  }

}


resource "aws_route_table" "terraform-public" {
  provider = aws.eastus
  vpc_id   = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "${var.Main_Routing_Table}"
  }
}

resource "aws_route_table_association" "terraform-public1" {
  provider       = aws.eastus
  subnet_id      = aws_subnet.subnet1-public.id
  route_table_id = aws_route_table.terraform-public.id
}

resource "aws_route_table_association" "terraform-public2" {
  provider       = aws.eastus
  subnet_id      = aws_subnet.subnet2-public.id
  route_table_id = aws_route_table.terraform-public.id
}

resource "aws_route_table_association" "terraform-public3" {
  provider       = aws.eastus
  subnet_id      = aws_subnet.subnet3-public.id
  route_table_id = aws_route_table.terraform-public.id
}

resource "aws_security_group" "allow_all" {
  provider    = aws.eastus
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.default.id
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

resource "aws_instance" "web-1" {
  provider                    = aws.eastus
  ami                         = "ami-0aa2b7722dc1b5612"
  availability_zone           = "us-east-1a"
  instance_type               = "t2.micro"
  key_name                    = "mykey"
  subnet_id                   = aws_subnet.subnet1-public.id
  vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address = true
  tags = {
    Name       = "US-Server-1"
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
	echo "<h1>US-Server-1</h1>" | sudo tee -a /var/www/html/index.nginx-debian.html
	EOF
}

# resource "aws_instance" "web-2" {
#   provider                    = aws.eastus
#   ami                         = "ami-0aa2b7722dc1b5612"
#   availability_zone           = "us-east-1a"
#   instance_type               = "t2.micro"
#   key_name                    = "LaptopKey"
#   subnet_id                   = aws_subnet.subnet1-public.id
#   vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
#   associate_public_ip_address = true
#   tags = {
#     Name       = "US-Server-2"
#     Env        = "Prod"
#     Owner      = "Sree"
#     CostCenter = "ABCD"
#   }
#   user_data = <<-EOF
# 	#!/bin/bash
#   sudo apt-get update
# 	sudo apt-get install -y nginx
# 	sudo systemctl start nginx
# 	sudo systemctl enable nginx
# 	echo "<h1>US-Server-2</h1>" | sudo tee -a /var/www/html/index.nginx-debian.html
# 	EOF
# }

# resource "aws_instance" "web-3" {
#   provider                    = aws.eastus
#   ami                         = "ami-0aa2b7722dc1b5612"
#   availability_zone           = "us-east-1a"
#   instance_type               = "t2.micro"
#   key_name                    = "LaptopKey"
#   subnet_id                   = aws_subnet.subnet1-public.id
#   vpc_security_group_ids      = ["${aws_security_group.allow_all.id}"]
#   associate_public_ip_address = true
#   tags = {
#     Name       = "US-Server-3"
#     Env        = "Prod"
#     Owner      = "Sree"
#     CostCenter = "ABCD"
#   }
#   user_data = <<-EOF
# 	#!/bin/bash
#   sudo apt-get update
# 	sudo apt-get install -y nginx
# 	sudo systemctl start nginx
# 	sudo systemctl enable nginx
# 	echo "<h1>US-Server-3</h1>" | sudo tee -a /var/www/html/index.nginx-debian.html
#   echo "<h1>NEW APP VERSION</h1>" | sudo tee -a /var/www/html/index.nginx-debian.html
# 	EOF
# }

