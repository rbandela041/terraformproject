resource "aws_instance" "web_server" {
  count                       = 3
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
    #!/bin/bash -xe
    sudo dnf update -y
    sudo dnf install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    sudo mkdir -p /etc/rahul
    echo "<h1>${local.vpc_name}-Public-server-${count.index}</h1>" > /usr/share/nginx/html/index.html
    sudo systemctl restart nginx
  EOF
}
