variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of your existing EC2 key pair"
  type        = string
  default     = "ec2_Rishi"
}

variable "ecr_repo" {
  description = "AWS ECR repository URI"
  type        = string
  default     = "130358282811.dkr.ecr.eu-north-1.amazonaws.com/cicd"
}

variable "sg_name" {
  description = "Name of security group"
  type        = string
  default     = "cicd-html-sg"
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "cicd-html-server"
}
