def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger'
]

pipeline{
    agent any

    stages{
        stage("Checkout from GITHUB"){
            steps{
                echo "========executing git checkout========"
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/marcmael1/devsecops.git']])
            }
            post{
                always{
                    echo "========always========"
                }
                success{
                    echo "========A executed successfully========"
                }
                failure{
                    echo "========A execution failed========"
                }
            }
        }

        stage("Maven Build and ARchiving"){
            steps{
                echo "========executing Maven build========"
                script{
                    sh 'mvn clean install -DskipTests=true'
                }
            }
            post{
                success{
                    echo "========Build executed successfully========"
                    archiveArtifacts artifacts: "**/*.jar"
                }
            }
        }

        stage("Unit Test and Jacoco reports"){
            steps{
                echo "====++++executing Unit Test and Jacoco reports++++===="
                script{
                    sh 'mvn test'
                }
            }
            post{
                always{
                    echo "====++++always++++===="
                    junit '**/surfire-reports/*.xml'
                    jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }
    }
    post{
        always{
            echo "========Slack Notification========"
            slackSend channel: '#jenkinscicd', 
                        color: COLOR_MAP[currentBuild.currentResult], 
                        message: "*${currentBuild.currentResult}:* Job $JOB_NAME Build $BUILD_ID \\n More infos at $BUILD_URL", 
                        teamDomain: 'devsecops-gyr2101', 
                        tokenCredentialId: 'slack-token'
        }
    }
}