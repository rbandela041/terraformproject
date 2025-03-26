variable "vpc_name" {}
variable "vpc_cidr" {}
variable "azs" {
  type = list(string)
}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "private_subnet_cidrs" {
  type = list(string)
}
variable "region" {}
variable "ami" {
  type = map(string)
}
variable "instance_type" {}
variable "key_name" {}
variable "dynamo_db" {}
variable "s3_bucket" {}
variable "test_role_arn" {}
variable "qa_role_arn" {}
variable "db_engine" {
  description = "RDS DB engine (e.g. mysql, postgres)"
  default     = "postgres"
}

variable "db_instance_class" {
  description = "Instance type for RDS"
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Master DB username"
}

variable "db_password" {
  description = "Master DB password"
  sensitive   = true
}

variable "db_storage" {
  description = "Allocated storage in GB"
  default     = 20
}

