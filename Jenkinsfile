pipeline {
    agent {
        docker {
            image 'krishdutta1177/maven-docker-agent:v5'
            args '--user root
        }
    }

    stages {
        stage('Clone repository') {
            steps {
                checkout scm
            }
        }
        stage('Build and Test') {
            steps {
                sh 'ls -ltr'
                sh 'mvn clean package'
            }
        }
        stage('Static Code Analysis') {
            environment {
                SONAR_URL = "http://3.83.87.3:9000"
            }
            steps {
                withCredentials([string(credentialsId: 'sonarqube', variable: 'SONAR_AUTH_TOKEN')]) {
                    sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
                }
            }
        }
        stage('Build and Push Docker Image') {
            environment {
                DOCKER_IMAGE = "krishdutta1177/ultimate-cicd:${BUILD_NUMBER}"
                REGISTRY_CREDENTIALS = credentials('docker-cred')
            }
            steps {
                script {
                    deleteDir() // Clean up workspace
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                    def dockerImage = docker.image("${DOCKER_IMAGE}")
                    docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Trigger ManifestUpdate') {
            steps {
                deleteDir() // Clean up workspace
                script {
                    echo "triggering updatemanifestjob"
                    build job: 'updatemanifest', parameters: [string(name: 'DOCKERTAG', value: env.BUILD_NUMBER)]
                }
            }
        }
    }
}
