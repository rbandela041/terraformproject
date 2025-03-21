resource "aws_instance" "web_server" {
  count                       = (var.env == "test" || var.env == "qa") ? 1 : 3
  ami                         = lookup(var.ami, var.region)
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.allow_all_sg.id]
  key_name                    = var.key_name
  subnet_id                   = element(aws_subnet.public-subnets[*].id, count.index)
  associate_public_ip_address = true

  tags = {
    Name  = "${local.vpc_name}-web-server-${count.index}"
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
    echo "<h1>${local.vpc_name}-Public-server-${count.index}</h1>" > /var/www/html/index.html
  EOF
}

