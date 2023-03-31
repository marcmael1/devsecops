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
                    archiveArtifacts artifacts: "target/*.jar"
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
        }

        stage("Pit mutation"){
            steps{
                echo "====++++executing Pit mutation++++===="
               sh 'mvn org.pitest:pitest-maven:scmMutationCoverage'
            }
            post{
                always{
                    echo "====++++always++++===="
                     pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                }
            }
        }

        stage("Static Code Analysis - SAST"){
            steps{
                echo "====++++executing Static Code Analysis - SAST++++===="
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }

        stage("Quality Gates"){
            steps{
                echo "====++++executing Quality Gates++++===="
                waitForQualityGate abortPipeline: true, credentialsId: 'slack-token'
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