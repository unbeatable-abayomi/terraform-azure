# 8. Output the Public IP
output "instance_public_ip_aws" {
  value = aws_instance.web.public_ip
}