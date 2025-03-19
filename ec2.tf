resource "aws_instance" "web_server" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.allow_all_sg.id]
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public-subnet-1.id
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
