variable "vpc_name" {}
variable "vpc_cidr" {}
variable "azs" {}
variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}
variable "region" {}
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "dynamo_db" {}
variable "s3_bucket" {}
variable "test_role_arn" {
  description = "IAM role for test environment"
  type        = string
  default     = "arn:aws:iam::442042517940:role/Terraformrole"
}

variable "qa_role_arn" {
  description = "IAM role for qa environment"
  type        = string
  default     = "arn:aws:iam::442042517940:role/QArole"
}

