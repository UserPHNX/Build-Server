pipeline {
    agent any

    environment {
        DOCKERHUB_CRED = credentials('docker-cred')
        IMAGE          = "userphnx/cw2-server:1.0"
        PROD_IP        = "ec2-13-221-145-169.compute-1.amazonaws.com"
    }

    triggers {
        pollSCM('* * * * *')
    }

    stages {

        stage('detect changes in repo') {
            steps {
                git branch: 'main', url: 'https://github.com/UserPHNX/Build-Server.git'
            }
        }

        stage('build docker image') {
            steps {
                sh 'docker build -t $IMAGE .'
            }
        }

        stage('test container launch') {
            steps {
                sh '''
                   docker run -d --name test-container $IMAGE
                   docker exec test-container echo "Container started successfully"
                   docker rm -f test-container
                '''
            }
        }

        stage('push image to docker') {
            steps {
                withDockerRegistry([credentialsId: 'docker-cred', url: '']) {
                    sh 'docker push $IMAGE'
                }
            }
        }

        stage('deploy to kubernetes') {
            steps {
                sshagent(credentials: ['prod-ssh-key']) {
                    sh '''
                       ssh -o StrictHostKeyChecking=no ubuntu@$PROD_IP \
                          "sudo kubectl set image deployment/cw2-image \
                           cw2-container=$IMAGE --record"
                    '''
                }
            }
        }
    }
}

