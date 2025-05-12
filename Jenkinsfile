pipeline {
    agent any

    tools {
        maven 'Maven 3.8.6' // Or whatever your Jenkins Maven tool name is
        jdk 'JDK17'         // Match this to your configured JDK in Jenkins
    }

    environment {
        // Optional: set Java home if needed
        JAVA_HOME = tool name: 'JDK17', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: 'github-creds', url: 'https://github.com/Karteekyvp/springboot-app-petclinic.git'
            }
        }

        stage('Build') {
            steps {
                bat 'mvn clean install'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('My SonarQube Server') {
                    bat '"C:\\ProgramData\\Jenkins\\.jenkins\\tools\\hudson.plugins.sonar.SonarRunnerInstallation\\SonarScanner\\bin\\sonar-scanner"'
                }
            }
        }
    }
}
