pipeline {
    agent any

    tools {
        maven 'Maven 3.8.6' // Make sure this matches your Jenkins tool config
        jdk 'JDK17'         // Same here
    }

    environment {
        JAVA_HOME = tool name: 'JDK17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Karteekyvp/springboot-app-petclinic.git'
            }
        }

        stage('Build') {
            steps {
                // Skip formatting and HTTP checks temporarily
                sh 'mvn clean install -Dspring-javaformat.skip=true -Dcheckstyle.skip=true'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('My SonarQube Server') {
                    // Run scanner assuming sonar-scanner is installed and in PATH
                    sh 'sonar-scanner'
                }
            }
        }
    }
}
