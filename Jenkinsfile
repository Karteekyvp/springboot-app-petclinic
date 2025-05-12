pipeline {
    agent any

    tools {
        sonarQubeScanner 'sonarQubeScanner'
    }

    environment {
        SONAR_SCANNER_HOME = tool 'sonarQubeScanner'
    }

    stages {
        stage('Clone GitHub Repo') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/Karteekyvp/springboot-app-petclinic.git'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('MySonarQube') {
                    sh "${SONAR_SCANNER_HOME}/bin/sonar-scanner"
                }
            }
        }
    }
}
