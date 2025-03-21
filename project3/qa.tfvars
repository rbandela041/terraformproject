vpc_name      = "Gamer-VPC"
vpc_cidr      = "192.168.0.0/16"
azs           = ["us-west-2a", "us-west-2b", "us-west-2c"]
public_subnet_cidrs = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
private_subnet_cidrs = ["192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
region        = "us-west-2"
instance_type = "t2.micro"
key_name      = "mykey"
env           = "qa"
ami           = {
  "us-west-2" = "ami-0c55b159cbfafe1f0"
  "us-east-1" = "ami-0c55b159cbfafe1f0"
}
dynamo_db     = "statelock"
s3_bucket     = "Vikingbucket"
test_role_arn = "arn:aws:iam::442042517940:user/terraform"
qa_role_arn   = "arn:aws:iam::442042517940:user/workspace"
