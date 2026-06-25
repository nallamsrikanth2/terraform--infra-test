pipeline {
    agent {
        label 'AGENT-1'
    }
    options {
        // Timeout counter starts BEFORE agent is allocated
        timeout(time: 1, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    stages {
        stage('Build') {
            steps {
                sh "echo This is Build"
            }
        }
        stage('Test') {
            steps {
                sh "echo This is Test"
                sh "sleep 2"
                sh "env"
            
            }
        }
        stage('Deploy') {
            steps {
                sh "echo This is Deploy"
            }
        }
    }
    post { 
        always { 
            echo 'I will always say Hello again!'
        }
        success {
            echo "I will run when pipeline is sucess"
        }
        failure {
            echo " i will when pipeline is failure"
        }
    }
}