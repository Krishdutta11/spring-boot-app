pipeline {
  agent {
    docker {
      image 'krishdutta1177/maven-docker-agent:v20'
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock' // mount Docker socket to access the host's Docker daemon
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
         sh 'ls -ltr'  // List files in the workspace
                sh 'ls -ltr /app'  // List files in the project directory
                sh 'mvn clean package'
      }
    }

    stage('Static Code Analysis') {
      environment {
        SONAR_URL = "http://34.235.114.52:9000"
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
    DOCKER_PATH = '/usr/bin/docker'  // Use the correct path to the Docker executable
  }
  steps {
    script {
      sh 'echo $PATH'
      sh 'echo "Build Number: ${BUILD_NUMBER}"'
      sh "${DOCKER_PATH} build -t ${DOCKER_IMAGE} ."
      def dockerImage = docker.image("${DOCKER_IMAGE}")
      docker.withRegistry('https://index.docker.io/v1/', "docker-cred") {
        dockerImage.push()
      }
    }
  }
}

    stage('Trigger ManifestUpdate') {
      steps {
        script {
          echo "triggering updatemanifestjob"
          build job: 'updatemanifest', parameters: [string(name: 'DOCKERTAG', value: env.BUILD_NUMBER)]
        }
      }
    }
  }
}
