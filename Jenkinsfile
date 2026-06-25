pipeline {
    agent {
        label 'AGENT-1'
    }
    options {
        // Timeout counter starts BEFORE agent is allocated
        timeout(time: 1, unit: 'MINUTES')
        disableConcurrentBuilds()
        ansiColor('xterm')
    }
    parameters {
        choice(name: 'ACTION', choices: ['Apply', 'Destroy'], description: 'Pick something')

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
            when {
                expression {
                    params.ACTION == 'Apply'
                }
            }
            steps {
                sh """
                    cd 01-vpc
                    terraform plan
                """
            
            }
        }
        stage('Deploy') {
             when {
                expression {
                    params.ACTION == 'Apply'
                }
            }
            steps {
                sh """
                 cd 01-vpc
                 terraform apply -auto-approve

                """
            }
        }
         stage('Destroy') {
             when {
                expression {
                    params.ACTION == 'Destroy'
                }
            }
            steps {
                sh """
                 cd 01-vpc
                 terraform destroy -auto-approve
                """
            }
        }
    }
    post { 
        always { 
            echo 'I will always say Hello again!'
            cleanWs()
        }
        success {
            echo "I will run when pipeline is sucess"
        }
        failure {
            echo " i will when pipeline is failure"
        }
    }
}