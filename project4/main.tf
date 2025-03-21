# Root-level main.tf with all logic combined

provider "aws" {
  region = var.region
  assume_role {
    role_arn = terraform.workspace == "test" ? var.test_role_arn : var.qa_role_arn
  }
}

resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = join("-", [var.vpc_name, terraform.workspace])
    env  = terraform.workspace
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = join("-", [var.vpc_name, terraform.workspace, "igw"])
    env  = terraform.workspace
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]
  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index}"
    env  = terraform.workspace
  }
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.azs[count.index]
  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index}"
    env  = terraform.workspace
  }
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt"
    env  = terraform.workspace
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.publicrt.id
}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "${var.vpc_name}-private-rt"
    env  = terraform.workspace
  }
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.privatert.id
}

resource "aws_security_group" "allow_all_sg" {
  name        = "allow-all-sg"
  description = "Allow all inbound and outbound traffic"
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
    Name = "${var.vpc_name}-power_star_sg"
  }
}

resource "aws_instance" "web_server" {
  count                       = (terraform.workspace == "test" || terraform.workspace == "qa") ? 1 : 3
  ami                         = lookup(var.ami, var.region)
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.allow_all_sg.id]
  key_name                    = var.key_name
  subnet_id                   = element(aws_subnet.public_subnets[*].id, count.index)
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, Terraform!" > /tmp/hello.txt
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>${var.vpc_name}-Public-server-${count.index}</h1>" > /var/www/html/index.html
  EOF
  tags = {
    Name  = "${var.vpc_name}-web-server-${count.index}"
    Env   = terraform.workspace
    Owner = "Rahul"
  }
}

resource "aws_lb" "alb" {
  name                       = "${var.vpc_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.allow_all_sg.id]
  subnets                    = aws_subnet.public_subnets[*].id
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "${var.vpc_name}-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc1.id
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_target_group_attachment" "alb_target_group_attachment" {
  count            = length(aws_instance.web_server[*].id)
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.web_server[count.index].id
  port             = 80
}

resource "random_integer" "gigabyte" {
  count = 3
  min   = 1000
  max   = 9999
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks-${random_integer.gigabyte[0].result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = lower(var.dynamo_db)
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket" "gigabyte" {
  count  = 3
  bucket = join("-", [lower(var.s3_bucket), terraform.workspace, random_integer.gigabyte[count.index].result])
  depends_on = [aws_dynamodb_table.terraform_locks]
  tags = {
    Name        = join("-", [lower(var.s3_bucket), terraform.workspace, random_integer.gigabyte[count.index].result])
    Environment = terraform.workspace
  }
}
