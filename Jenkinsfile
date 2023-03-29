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
                    sh 'mvn clean install -DskipTests=true'
                }
            }
            post{
                success{
                    echo "====++++ Archiving Artifact ++++===="
                    archiveArtifacts artifacts: "**/*.jar"
                }
            }
        }
        stage("Unit Test & Jacoco report"){
            steps{
                script{
                     echo "====++++executing Unit Test & Jacoco report++++===="
                     sh 'mvn test'
                }
            }
            post{
                always{
                    echo "====++++ Publish report to jenkins UI++++===="
                    junit "target/surefire-reports/*.xml"
                    jacoco execPattern: "target/*.exec"

                }
            }
        }

        stage('Mutations Test'){
            steps{
                script{
                    sh 'mvn org.pitest:pitest-maven:mutationCoverage'
                }
            }
            post{
                always{
                    echo "====++++ PIT Mutations report++++===="
                    pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                }
            }
        }

        stage('SonarQube - SAST'){
            steps{
                echo "====++++  static code analysis++++===="
                script{
                  withSonarQubeEnv(credentialsId: 'sonar-token') {
                    sh 'mvn clean verify sonar:sonar'
                  }  
                }
            }
        }

        stage('Quality Gates'){
            steps{
                timeout(time: 3, unit: "MINUTES")
                script{
                   waitForQualityGate abortPipeline: true, credentialsId: 'sonar-token' 
                }
            }
        }

        // stage("Dependency Check"){
        //     steps{
        //         script{
        //             echo "====++++executing Dependency Check++++===="
        //             sh 'mvn dependecy-check:check'
        //         }
        //     }
        //     post{
        //         always{
        //             echo "====++++always++++===="
        //             dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        //         }
        
        //     }
        // }
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