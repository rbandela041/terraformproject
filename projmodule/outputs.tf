output "vpc_id" {
  value = module.infra.vpc_id
}

output "public_subnet_ids" {
  value = module.infra.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.infra.private_subnet_ids
}

output "security_group_id" {
  value = module.infra.security_group_id
}

output "ec2_instance_ids" {
  value = module.infra.ec2_instance_ids
}

output "ec2_public_ips" {
  value = module.infra.ec2_public_ips
}

output "alb_dns_name" {
  value = module.infra.alb_dns_name
}

output "s3_bucket_names" {
  value = module.infra.s3_bucket_names
}

output "dynamodb_table_name" {
  value = module.infra.dynamodb_table_name
}

# If you added RDS
output "rds_endpoint" {
  value = module.infra.rds_endpoint
}

output "detected_postgres_version" {
  value = module.infra.postgres_engine_version
}

