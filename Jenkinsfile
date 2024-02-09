pipeline {
    agent {
        docker {
            image 'krishdutta1177/ultimate-cicd-pipeline:v2'
            args '--user root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=""' // Add --entrypoint=""
        }
    }

    stages {
        stage('Pre-Build Checks') {
            steps {
                script {
                    echo "Checking if Maven is installed..."
                    sh 'mvn --version' // Execute mvn --version to check if Maven is installed
                }
            }
        }

        stage('Clone repository') {
            steps {
                echo "Cloning repository..."
                checkout scm
            }
        }

        stage('Build and Test') {
            steps {
                echo "Listing files in the workspace..."
                sh 'ls -ltr'  // List files in the workspace
                sh 'mvn clean package'
            }
        }

        stage('Static Code Analysis') {
            environment {
                SONAR_URL = "http://54.146.58.161:9000"
            }
            steps {
                echo "Running static code analysis..."
                withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
                }
            }
        }

        stage('Build and Push Docker Image') {
            environment {
                DOCKER_IMAGE = "krishdutta1177/ultimate-cicd:${BUILD_NUMBER}"
                REGISTRY_CREDENTIALS = credentials('docker-cred')
                DOCKER_PATH = '/usr/bin/docker'  // Use the correct path to the Docker executable
            }
            steps {
                script {
                    echo "Building Docker image..."
                    sh 'echo $PATH'
                    echo "Build Number: ${BUILD_NUMBER}"
                    sh "${DOCKER_PATH} build -t ${DOCKER_IMAGE} ."
                    def dockerImage = docker.image("${DOCKER_IMAGE}")
                    echo "Pushing Docker image..."
                    docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Trigger ManifestUpdate') {
            steps {
                script {
                    echo "Triggering updatemanifestjob..."
                    build job: 'updatemanifest', parameters: [string(name: 'DOCKERTAG', value: env.BUILD_NUMBER)]
                }
            }
        }

        stage('Debugging') {
            steps {
                echo "Debugging Docker container..."
                sh 'docker ps -a'
                sh 'docker logs <container_id>' // Replace <container_id> with the actual container ID
                sh 'docker exec <container_id> ls -l /app'
                // Add more debugging commands as needed
            }
        }
    }
}

