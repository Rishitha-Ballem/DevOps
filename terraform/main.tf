terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# ------------------------------
# Fetch latest Amazon Linux 2 AMI
# ------------------------------
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

# ------------------------------
# Security Group for HTTP + SSH
# ------------------------------
resource "aws_security_group" "ci_cd_sg" {
  name        = var.sg_name
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}

# ------------------------------
# EC2 Instance (runs Docker container)
# ------------------------------
resource "aws_instance" "ci_cd_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ci_cd_sg.id]
associate_public_ip_address = true  
  user_data = <<-EOF
              #!/bin/bash
              set -e
              yum update -y
              yum install -y docker awscli
              systemctl enable docker
              systemctl start docker
              
              # Login to ECR and run container
              aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.ecr_repo}
              docker pull ${var.ecr_repo}:latest
              docker run -d -p 80:80 ${var.ecr_repo}:latest
              EOF

  tags = {
    Name = var.instance_name
  }

  metadata_options {
    http_tokens = "required"
  }
}
