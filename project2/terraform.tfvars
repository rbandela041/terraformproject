vpc_name             = "Gamer-VPC"
vpc_cidr             = "192.168.0.0/16"
azs                  = ["us-west-2a", "us-west-2b", "us-west-2c"]
public_subnet_cidrs  = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
private_subnet_cidrs = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
region               = "us-west-2"
instance_type        = "t2.micro"
key_name             = "mykey"
env                  = "test"
ami = {
  "us-west-2" = "ami-0b6d6dacf350ebc82"
  "us-east-1" = "ami-0b6d6dacf350ebc82"
}

