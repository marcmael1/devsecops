def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger'
]

pipeline{
    agent any

    stages{
        stage('Clean Workspace'){
            steps{
                script{
                    cleanWs()
                }
            }
        }
        stage("CODE CHECKOUT"){
            steps{
                echo "========executing CODE CHECKOUT========"
                script{
                    checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/marcmael1/devsecops.git']])
                }
            }
        }

        stage("MAVEN BUILD"){
            steps{
                echo "====++++executing MAVEN BUILD++++===="
                script{
                    sh 'mvn clean install -DskipTests=true'
                }
            }
            post{
                success{
                    echo "====++++MAVEN BUILD executed successfully++++===="
                    echo "====++++Archiving Artifact++++===="
                    archiveArtifacts artifacts: "target/*.jar"
                }
            }
        }
    }
    post{
        always{
            echo "========Slack Notification========"
            slackSend channel: '#jenkinscicd', 
                        color: COLOR_MAP[currentBuild.currentResult], 
                        message: "*${currentBuild.currentResult}:* Job $JOB_NAME Build $BUILD_ID \\n More info at $BUILD_URL", 
                        teamDomain: 'devsecops-gyr2101', 
                        tokenCredentialId: 'slack-token'
        }
    }
}