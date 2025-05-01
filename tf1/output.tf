###creating output for public ip and pubilc dns of the instance
output "public_ip" { #you can change the name of the output as per your requirement
  value = aws_instance.ec2-1.public_ip
}

output "public_dns" { #you can change the name of the output as per your requirement
  value = aws_instance.ec2-1.public_dns
}
output "vpc_id" { #you can change the name of the output as per your requirement
  value = aws_vpc.vpc-1.id
}
