pipeline {
    agent any

    environment {
        DOCKERHUB_CRED = credentials('docker-cred')
        SSH_KEY        = credentials('prod-ssh-key')
        IMAGE          = "userphnx/cw2-server:1.0"
        PROD_IP        = "ec2-13-221-145-169.compute-1.amazonaws.com"
    }

    triggers {
        pollSCM('* * * * *')
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/UserPHNX/Build-Server.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withDockerRegistry([credentialsId: "${DOCKERHUB_CRED}", url: '']) {
                    sh 'docker push $IMAGE'
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent(credentials: ["$SSH_KEY"]) {
                    sh '''
                       ssh -o StrictHostKeyChecking=no ubuntu@$PROD_IP \
                          "kubectl set image deployment/cw2-image \
                           cw2-container=$IMAGE --record"
                    '''
                }
            }
        }
    }
}

