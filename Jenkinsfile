pipeline {
    agent any

    environment {
        PROJECT_KEY = 'springboot-petclinic'
        SONAR_SCANNER_OPTS = "-Dsonar.projectKey=${PROJECT_KEY} -Dsonar.java.binaries=target/classes"
    }

    stages {

        stage('Build with Maven') {
            steps {
                echo "Building Spring Boot application..."
                sh './mvnw clean package'
            }
        }

        stage('SonarQube Scan') {
            steps {
                echo "Running SonarQube scanner..."
                withSonarQubeEnv('sonar-jenkins') {
                    sh './mvnw sonar:sonar'
                }
            }
        }

        stage('Print Report File (Optional JSON)') {
            steps {
                echo "Searching for SonarQube task report..."
                sh 'cat target/sonar/report-task.txt || echo "No report-task.txt found!"'
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline succeeded. View results at SonarQube dashboard."
        }
        failure {
            echo "❌ Pipeline failed. Check logs and SonarQube."
        }
    }
}
