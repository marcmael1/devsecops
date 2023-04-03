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

        stage("UNIT TEST & JACOCO"){
            steps{
                echo "====++++executing UNIT TEST & JACOCO++++===="
                script{
                    sh 'mvn test'
                }
            }
            post{
                always{
                    echo "====++++JUNIT & JACOCO++++===="
                    junit '**/target/surefire-reports/*.xml'
                    jacoco execPattern: '**/target/*.exec'
                }
            }
        }

        stage("MUTATION TEST - PIT MUTATION"){
            steps{
                echo "====++++executing MUTATION TEST - PIT MUTATION++++===="
                script{
                    sh 'mvn org.pitest:pitest-maven:mutationCoverage'
                }
            }
            post{
                always{
                    echo "====++++MUTATION REPORTS++++===="
                    pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                }
            }
        }

        stage("SONARQUBE - SAST"){
            steps{
                echo "====++++executing SONARQUBE - SAST++++===="
                script{
                    withSonarQubeEnv('SonarQube') {
                        sh 'mvn clean package sonar:sonar'
                    }
                }
            }
            post{
                always{
                    echo "====++++Quality Gates++++===="
                    timeout(time: 2, unit: "MINUTES"){
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

        stage("Nexus artifact"){
            steps{
                echo "====++++executing Nexus artifact++++===="
                script{
                    def readPomVersion = readMavenPom file: 'pom.xml'
                        chooseNexusRepo = readPomVersion.version.endsWith("SNAPSHOT") ? "devsecops-numeric-app-snapshot" : "devsecops-numeric-app-release"

                   nexusArtifactUploader artifacts: 
                   [
                        [
                            artifactId: 'numeric', 
                            classifier: '', 
                            file: 'target/numeric.jar', 
                            type: 'jar'
                        ]
                    ], 
                    credentialsId: 'nexus-cred', 
                    groupId: 'com.devsecops', 
                    nexusUrl: '3.83.149.207:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: chooseNexusRepo, 
                    version: readPomVersion.version     
                }
            }
        }

        stage("DEPENDENCY CHECK-OWASP"){
            steps{
                echo "====++++executing DEPENDENCY CHECK-OWASP++++===="
                script{
                    sh 'mvn dependency-check:check'
                }
            }
            post{
                always{
                    echo "====++++DEPENDENCY CHECK REPORTS++++===="
                    dependencyCheckPublisher pattern: '**/target/dependency-check-report.xml'
                }
            }
        }

        stage("BASE IMAGE SCAN - TRIVY "){
            steps{
                echo "====++++executing BASE IMAGE SCAN - TRIVY ++++===="
                script{
                    sh 'bash trivy-docker-image-scan.sh'
                }
            }
        }

        stage('OPA CONFTEST'){
            steps{
                script{
                    sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
                }
            }
        }

        stage('DOCKER BUILD & TAG'){
            steps{
                script{
                    sh 'docker image build -t $JOB_NAME:v1.$BUILD_ID .'
                    sh 'docker image tag $JOB_NAME:v1.$BUILD_ID marcmael/$JOB_NAME:v1.$BUILD_ID'
                    sh 'docker image tag $JOB_NAME:v1.$BUILD_ID marcmael/$JOB_NAME:latest'
                }
            }
        }

        stage('PUSH IMAGE TO DOCKERHUB'){
            steps{
                echo " ###### Pushing image to dockerhub #######"
                script{
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh 'docker push marcmael/$JOB_NAME:v1.$BUILD_ID'
                        sh 'docker push marcmael/$JOB_NAME:latest'
                    }
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