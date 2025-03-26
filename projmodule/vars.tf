variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "ami" {
  description = "Map of region to AMI ID"
  type        = map(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "dynamo_db" {
  description = "Name prefix for DynamoDB lock table"
  type        = string
}

variable "s3_bucket" {
  description = "Name prefix for S3 buckets"
  type        = string
}

variable "test_role_arn" {
  description = "IAM role ARN for the test environment"
  type        = string
  default     = "arn:aws:iam::442042517940:role/Terraformrole"
}

variable "qa_role_arn" {
  description = "IAM role ARN for the QA environment"
  type        = string
  default     = "arn:aws:iam::442042517940:role/QArole"
}

variable "db_engine" {
  description = "RDS DB engine (e.g. mysql, postgres)"
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Engine version (e.g. 15.3 for postgres)"
  default     = "15.3"
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

variable "db_family" {
  description = "DB parameter group family (e.g. postgres15)"
  default     = "postgres15"
}
