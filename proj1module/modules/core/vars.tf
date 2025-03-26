variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr1" {
  description = "CIDR block for public subnet 1"
  type        = string
}

variable "subnet_cidr2" {
  description = "CIDR block for public subnet 2"
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, test)"
  type        = string
}

