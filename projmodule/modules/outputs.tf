output "vpc_id" {
  value       = aws_vpc.vpc1.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = aws_subnet.public-subnets[*].id
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = aws_subnet.private-subnets[*].id
  description = "List of private subnet IDs"
}

output "security_group_id" {
  value       = aws_security_group.allow_all_sg.id
  description = "Security group ID"
}

output "ec2_instance_ids" {
  value       = aws_instance.web_server[*].id
  description = "EC2 instance IDs"
}

output "ec2_public_ips" {
  value       = aws_instance.web_server[*].public_ip
  description = "Public IPs of EC2 instances"
}

output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "ALB DNS Name"
}

output "s3_bucket_names" {
  value       = aws_s3_bucket.gigabyte[*].bucket
  description = "List of created S3 bucket names"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB lock table name"
}


output "rds_endpoint" {
  value       = aws_db_instance.rds.endpoint
  description = "RDS Endpoint"
}

output "postgres_engine_version" {
  value       = data.aws_rds_engine_version.postgres.version
  description = "Detected Postgres engine version"
}

