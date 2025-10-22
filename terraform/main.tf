resource "aws_instance" "ci_cd_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo docker login -u AWS -p $(aws ecr get-login-password --region ap-south-1) <your-aws-account-id>.dkr.ecr.ap-south-1.amazonaws.com
              sudo docker pull <your-aws-account-id>.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-test:latest
              sudo docker run -d -p 80:80 <your-aws-account-id>.dkr.ecr.ap-south-1.amazonaws.com/ci-cd-test:latest
              EOF

  tags = {
    Name = "CI-CD-Server"
  }
}
