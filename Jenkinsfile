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
                // Pulls code from the Git repo configured in the Jenkins Job
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
                    // 'dockerhub-auth' is the ID we just set in Jenkins Credentials
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-auth', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo ${PASS} | docker login -u ${USER} --password-stdin"
                        sh "docker push ${BACKEND_IMAGE}"
                        sh "docker push ${FRONTEND_IMAGE}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully pushed images to https://hub.docker.com/u/${DOCKER_USER}"
        }
        failure {
            echo "Build failed. Check Console Output for errors."
        }
    }
}
