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
    }
    post{
        always{
            echo "======== Alerting Team ========"
            slackSend channel: '#jenkinscicd', 
                        color: COLOR_MAP[currentBuild.currentResult], 
                        message: '"*${currentBuild.currentResult}:* Job ${env.BUILD_NAME} Build ${env.BUILD_ID}  \\n More infos at ${env.BUILD_URL}"', teamDomain: 'devsecops-gyr2101', 
                        tokenCredentialId: 'slack-token'
        }
    }
}