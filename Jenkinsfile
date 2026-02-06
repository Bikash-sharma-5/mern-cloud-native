pipeline {
    agent any

    // This ensures Jenkins uses the Docker CLI tool we configured in Global Tools
 
    environment {
        DOCKER_USER = 'sharmajikechhotebete'
        BACKEND_IMAGE = "${DOCKER_USER}/mern-backend:latest"
        FRONTEND_IMAGE = "${DOCKER_USER}/mern-frontend:latest"
    }

    stages {
        stage('Cleanup') {
            steps {
                echo 'Cleaning up workspace...'
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Images') {
            steps {
                script {
                    echo "Starting build for Backend..."
                    sh "docker build -t ${BACKEND_IMAGE} ./backend"
                    
                    echo "Starting build for Frontend..."
                    sh "docker build -t ${FRONTEND_IMAGE} ./frontend"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-auth', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                        sh "docker push ${BACKEND_IMAGE}"
                        sh "docker push ${FRONTEND_IMAGE}"
                    }
                }
            }
        }

        stage('CD: Terraform Deploy & Monitoring') {
            steps {
                dir('infrastructure') {
                    script {
                        echo "Initializing Terraform..."
                        sh "terraform init"
                        echo "Deploying MERN Stack + Prometheus + Grafana..."
                        sh "terraform apply -auto-approve"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "CI/CD Pipeline Successful!"
            echo "App deployed to Kubernetes."
            echo "Monitoring active (Prometheus/Grafana)."
        }
        failure {
            echo "Build failed. Check Console Output for errors."
        }
    }
}
