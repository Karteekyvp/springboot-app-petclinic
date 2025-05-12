pipeline {
    agent any


    environment {
        SONAR_SCANNER_HOME = tool 'SonarScanner'  // Use this tool in the pipeline
    }

    stages {
        stage('Clone GitHub Repo') {
            steps {
               git branch: 'main', url: 'https://github.com/Karteekyvp/springboot-app-petclinic.git'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('My SonarQube Server') {  // Ensure 'My SonarQube Server' is the correct configuration name
                    bat "\"${SONAR_SCANNER_HOME}\\bin\\sonar-scanner\""
                }
            }
        }
    }
}
