# Output value definitions

############################################### [S3|Lambda] Outputs

output "public_ec2_dns" {
  description = "Public EC2 DNS."

  value = aws_instance.service.public_dns
}



###############################################
