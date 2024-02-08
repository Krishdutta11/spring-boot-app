pipeline {
  agent {
    docker {
      image 'krishdutta1177/maven-docker-image:v12'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
    }
  }

    stages {
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
                echo "Building and testing..."
                sh 'mvn clean package'
            }
        }

        stage('Static Code Analysis') {
            environment {
                SONAR_URL = "http://3.84.237.5:9000"
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
                    sh 'echo "Build Number: ${BUILD_NUMBER}"'
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

