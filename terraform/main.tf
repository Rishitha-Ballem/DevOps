terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "eu-north-1"
}

# Fetch latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

# Security Group for HTTP + SSH
resource "aws_security_group" "ci_cd_sg" {
  name        = "cicd-html-sg"
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
    Name = "cicd-html-sg"
  }
}

# IAM Role for EC2 to pull from ECR
resource "aws_iam_role" "ec2_role" {
  name = "cicd-html-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach ECR and SSM permissions
resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "cicd-html-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Instance
resource "aws_instance" "ci_cd_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  key_name               = "ec2_Rishi"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ci_cd_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e
              yum update -y
              yum install -y docker awscli
              systemctl enable docker
              systemctl start docker
              aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 130358282811.dkr.ecr.eu-north-1.amazonaws.com
              docker pull 130358282811.dkr.ecr.eu-north-1.amazonaws.com/cicd:latest
              docker run -d -p 80:80 130358282811.dkr.ecr.eu-north-1.amazonaws.com/cicd:latest
              EOF

  tags = {
    Name = "cicd-html-server"
  }

  metadata_options {
    http_tokens = "required"
  }
}
