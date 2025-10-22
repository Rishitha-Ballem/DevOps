resource "aws_instance" "ci_cd_instance" {
  ami           = var.ami_id        # Make sure var.ami_id is a valid AMI in your region
  instance_type = "t2.micro"        # Correct EC2 instance type
  key_name      = var.key_name
  vpc_security_group_ids = [var.security_group]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo docker login -u AWS -p $(aws ecr get-login-password --region eu-north-1) 130358282811.dkr.ecr.eu-north-1.amazonaws.com
              sudo docker pull 130358282811.dkr.ecr.eu-north-1.amazonaws.com/cicd:latest
              sudo docker run -d -p 80:80 130358282811.dkr.ecr.eu-north-1.amazonaws.com/cicd:latest
              EOF

  tags = {
    Name = "CI-CD-Server"
  }
}
