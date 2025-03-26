######################
# VPC and Networking #
######################

resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "vpc1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.subnet_cidr1
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "${var.vpc_name}-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.subnet_cidr2
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "${var.vpc_name}-public-subnet-2"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

##########################
# Security Group         #
##########################

resource "aws_security_group" "allow_all_sg" {
  name        = "allow-all-sg"
  description = "Security group allowing all traffic"
  vpc_id      = aws_vpc.vpc1.id

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

  tags = {
    Name = "${var.vpc_name}-sg"
  }
}

##################
# EC2 Instance   #
##################

resource "aws_instance" "web_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.allow_all_sg.id]
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true

  tags = {
    Name  = "KingKhan"
    Env   = var.env
    Owner = "Rahul"
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, Terraform!" > /tmp/hello.txt
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>Welcome to Amazon Linux with Terraform</h1>" > /var/www/html/index.html
  EOF
}

#################
# S3 + DynamoDB #
#################

resource "random_integer" "gigabyte" {
  min = 1000
  max = 9999
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-${random_integer.gigabyte.result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Locks Table"
    Environment = var.env
  }
}

resource "aws_s3_bucket" "gigabyte" {
  count  = 3
  bucket = "my-bucket-${random_integer.gigabyte.result}-${count.index}"

  depends_on = [aws_dynamodb_table.terraform_locks]

  tags = {
    Name        = "gigabyte ${count.index}"
    Environment = var.env
  }
}

