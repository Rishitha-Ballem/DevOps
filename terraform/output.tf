# ===============================
# Outputs for EC2 + Web URL
# ===============================

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.ci_cd_instance.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.ci_cd_instance.public_ip
}

output "public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.ci_cd_instance.public_dns
}

output "web_url" {
  description = "Access your HTML page via this URL"
  value       = "http://${aws_instance.ci_cd_instance.public_ip}"
}
