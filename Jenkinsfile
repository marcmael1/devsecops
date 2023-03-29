def COLOR_MAP = [
    'SUCCESS': 'good',
    'FAILURE': 'danger'
]

pipeline{
    agent any

    stages{
        stage('Checkout from GITHUB'){
            steps{
                echo "======== Checkout from vcs ========"
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/marcmael1/devsecops.git']])
            }
        }

        stage('Maven Build'){
            steps{
                script{
                    sh 'mvn clean install'
                }
            }
            post{
                success{
                    echo "====++++ Archiving Artifact ++++===="
                    archiveArtifacts artifacts: "**/*.jar"
            }
        }
    }
    post{
        always{
            echo "======== Alerting Team ========"
            slackSend channel: '#jenkinscicd', 
                        color: COLOR_MAP[currentBuild.currentResult], 
                        message: "*${currentBuild.currentResult}:* Job $JOB_NAME Build $BUILD_ID  \\n More infos at $BUILD_URL", 
                        teamDomain: 'devsecops-gyr2101', 
                        tokenCredentialId: 'slack-token'
        }
    }
}