resource "aws_security_group" "allow_all_sg" {
  name        = "allow-all-sg"
  description = "Security group allowing all ingress and egress traffic"
  vpc_id      = aws_vpc.vpc1.id # Replace with your VPC ID

  # Ingress Rule - Allow All Traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allows all IPv4 traffic
  }

  # Egress Rule - Allow All Traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allows all IPv4 traffic
  }

  tags = {
    Name = "${local.vpc_name}-power_star_sg"
  }
}
