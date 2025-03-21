output "alb_dns_name" {
  value = aws_lb.alb.dns_name
  description = "DNS name of the ALB"
}

output "web_server_ips" {
  value = aws_instance.web_server[*].public_ip
  description = "Public IPs of the web servers"
}

output "s3_bucket_names" {
  value = aws_s3_bucket.gigabyte[*].bucket
  description = "Names of the S3 buckets"
}
