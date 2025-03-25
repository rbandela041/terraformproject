provider "aws" {
  region = var.region
}

resource "aws_instance" "instance1" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key_name
    subnet = var.subnet_id
    tags = {
        Name = var.name
    }
output "instance_ip" {
    value = aws_instance.instance1.public_ip
}