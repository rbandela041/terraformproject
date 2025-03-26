output "public_dns" {
  value       = aws_instance.web_server.public_dns
  description = "Public DNS of the EC2 instance"
}

output "public_ip" {
  value       = aws_instance.web_server.public_ip
  description = "Public IP of the EC2 instance"
}

output "random_number" {
  value       = random_integer.gigabyte.result
  description = "Random number used in resource naming"
}

output "s3_bucket_names" {
  value       = aws_s3_bucket.gigabyte[*].bucket
  description = "List of S3 bucket names"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB table name for state locking"
}

