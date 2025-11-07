pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        ECR_REPO   = '130358282811.dkr.ecr.eu-north-1.amazonaws.com/cicd'
        IMAGE_NAME = 'cicd'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Rishitha-Ballem/DevOps'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REPO}
                    """
                }
            }
        }

        stage('Tag and Push Docker Image') {
            steps {
                sh """
                    docker tag ${IMAGE_NAME}:latest ${ECR_REPO}:latest
                    docker push ${ECR_REPO}:latest
                """
            }
        }

        stage('Terraform Deploy EC2') {
            steps {
                dir('terraform') {
                    withAWS(credentials: 'aws-credentials', region: "${AWS_REGION}") {
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }

   stage('Deploy Application on EC2') {
    steps {
        script {
            // Get EC2 Public IP dynamically from Terraform output
            def EC2_IP = sh(
                script: "cd terraform && terraform output -raw public_ip",
                returnStdout: true
            ).trim()

            // Load EC2 SSH key using ssh-agent
            sshagent(credentials: ['ec2-ssh-key']) {
                sh """
                    ssh -o StrictHostKeyChecking=no ec2-user@${EC2_IP} '
                        echo "Stopping old container (if exists)..."
                        sudo docker stop cicd || true
                        sudo docker rm cicd || true

                        echo "Removing old image..."
                        sudo docker rmi ${ECR_REPO}:latest || true

                        echo "Logging into ECR..."
                        aws ecr get-login-password --region ${AWS_REGION} | \
                            sudo docker login --username AWS --password-stdin ${ECR_REPO}

                        echo "Pulling latest Docker image..."
                        sudo docker pull ${ECR_REPO}:latest

                        echo "Starting new container..."
                        sudo docker run -d --name cicd -p 80:80 ${ECR_REPO}:latest

                        echo "Deployment Successful on EC2!"
                    '
                """
            }
        }
    }
}


    }

    post {
        success {
            echo "Deployment Completed Successfully!"
        }
        failure {
            echo "Pipeline Failed!"
        }
    }
}
