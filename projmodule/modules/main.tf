####################
# VPC & Networking #
####################
resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = join("-", [local.vpc_name, local.env])
    env  = local.env
  }
}

resource "aws_internet_gateway" "vpc1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = join("-", [local.vpc_name, local.env, "igw"])
    env  = local.env
  }
}

#################
# Subnet Blocks #
#################
resource "aws_subnet" "public-subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs, count.index)

  tags = {
    Name = "${local.vpc_name}-public-subnet-${count.index}"
    env  = local.env
  }
}

resource "aws_subnet" "private-subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = element(var.private_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.azs, count.index)

  tags = {
    Name = "${local.vpc_name}-private-subnet-${count.index}"
    env  = local.env
  }
}

##################
# Route Tables   #
##################
resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc1.id
  }

  tags = {
    Name = "${local.vpc_name}-public-rt"
    env  = local.env
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
    env  = local.env
  }
}

resource "aws_route_table_association" "private-rt-assoc" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private-subnets[*].id, count.index)
  route_table_id = aws_route_table.privatert.id
}

##########################
# Security Group         #
##########################
resource "aws_security_group" "allow_all_sg" {
  name        = "allow-all-sg"
  description = "Security group allowing all ingress and egress traffic"
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
    Name = "${local.vpc_name}-power_star_sg"
  }
}

#####################
# EC2 Web Instances #
#####################
resource "aws_instance" "web_server" {
  count                       = (local.env == "test" || local.env == "qa") ? 1 : 3
  ami                         = lookup(var.ami, var.region)
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.allow_all_sg.id]
  key_name                    = var.key_name
  subnet_id                   = element(aws_subnet.public-subnets[*].id, count.index)
  associate_public_ip_address = true

  tags = {
    Name  = "${local.vpc_name}-web-server-${count.index}"
    Env   = local.env
    Owner = "Rahul"
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, Terraform!" > /tmp/hello.txt
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>${local.vpc_name}-Public-server-${count.index}</h1>" > /var/www/html/index.html
  EOF
}

############
# ALB      #
############
resource "aws_lb" "alb" {
  name                       = "${local.vpc_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.allow_all_sg.id]
  subnets                    = aws_subnet.public-subnets[*].id
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60
}

resource "aws_lb_target_group" "alb_target_group" {
  name     = "${local.vpc_name}-alb-target-group"
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
  count            = 3
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = element(aws_instance.web_server[*].id, count.index)
  port             = 80
}

##############
# S3 & Lock  #
##############
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
    Name        = local.dynamo_db
    Environment = local.env
  }
}

resource "aws_s3_bucket" "gigabyte" {
  count  = 3
  bucket = join("-", [local.s3_bucket, terraform.workspace, random_integer.gigabyte[count.index].result])

  depends_on = [aws_dynamodb_table.terraform_locks]

  tags = {
    Name        = join("-", [local.s3_bucket, terraform.workspace, random_integer.gigabyte[count.index].result])
    Environment = local.env
  }
}

###################################
# RDS Parameter Group
###################################
resource "aws_db_parameter_group" "rds_pg" {
  name        = "${local.vpc_name}-rds-pg"
  family      = data.aws_rds_engine_version.postgres.parameter_group_family
  description = "RDS parameter group for ${local.vpc_name}"

  tags = {
    Name = "${local.vpc_name}-rds-pg"
    Env  = local.env
  }
}

###################################
# RDS Subnet Group
###################################
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${local.vpc_name}-rds-subnet-group"
  subnet_ids = aws_subnet.private-subnets[*].id

  tags = {
    Name = "${local.vpc_name}-rds-subnet-group"
    Env  = local.env
  }
}

###################################
# RDS Instance
###################################
data "aws_rds_engine_version" "postgres" {
  engine = "postgres"
}
resource "aws_db_instance" "rds" {
  allocated_storage    = var.db_storage
  engine               = var.db_engine
  engine_version       = data.aws_rds_engine_version.postgres.version
  instance_class       = var.db_instance_class
  identifier           = "${local.vpc_name}-rds"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = aws_db_parameter_group.rds_pg.name
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.allow_all_sg.id]

  skip_final_snapshot = true

  tags = {
    Name = "${local.vpc_name}-rds"
    Env  = local.env
  }
}

