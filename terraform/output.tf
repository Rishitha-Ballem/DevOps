output "public_ip" {
  value = aws_instance.ci_cd_instance.public_ip
}
