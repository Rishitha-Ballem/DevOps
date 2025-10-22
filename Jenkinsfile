pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
        ECR_REPO = '130358282811.dkr.ecr.eu-north-1.amazonaws.com/cicd'
        IMAGE_NAME = 'cicd'
    }

  stage('Checkout Code') {
      steps {
          git branch: 'main',
              url: 'https://github.com/Rishitha-Ballem/DevOps'
      }
  }


        stage('Build Docker Image') {
            steps {
                script {
                    echo "🚧 Building Docker image..."
                    sh 'docker build -t ${IMAGE_NAME}:latest .'
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    script {
                        echo "🔐 Logging in to ECR..."
                        sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REPO}
                        '''
                    }
                }
            }
        }

        stage('Tag and Push Docker Image') {
            steps {
                script {
                    echo "📦 Tagging and pushing image to ECR..."
                    sh '''
                    docker tag ${IMAGE_NAME}:latest ${ECR_REPO}:latest
                    docker push ${ECR_REPO}:latest
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Docker image successfully built and pushed to ECR: ${ECR_REPO}:latest"
        }
        failure {
            echo "❌ Pipeline failed — check console output for errors."
        }
    }
}
