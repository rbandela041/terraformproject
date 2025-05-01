resource "aws_instance" "ec2-1" {
  ami                    = "ami-0e449927258d45bc4" # Amazon Linux 2023 AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet-1.id
  vpc_security_group_ids = [aws_security_group.sg-1.id, aws_security_group.sg-2.id]
  key_name               = "mykey"

  ##Create userdata script to install Apache web server on amazon linux 2023
  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<h1>Hello from Terraform</h1>" > /var/www/html/index.html
              sudo systemctl restart httpd
              sudo systemctl enable httpd
              EOF

  tags = {
    Name = "Kalki-EC2"
  }
}
