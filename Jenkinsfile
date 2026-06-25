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
        stage('init') {
            steps {
                sh """
                    ls -ltr
                    cd 01-vpc
                    terraform init -reconfigure
                """
            }
        }
        stage('plan') {
            steps {
                sh "echo This is Test"
            
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