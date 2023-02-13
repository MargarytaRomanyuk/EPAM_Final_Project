pipeline {
    agent any
    tools {
        maven 'maven-3.8'
    }
    stages {
        stage("init") {
            steps {
                script {
                    gv = load "script.groovy"
                }
            }
        }
        stage("incremental version") {
            when {
                expression {
                    BRANCH_NAME == 'dev'
                }
            }   
            steps {
                script { 
                    echo 'Parsing and incrementing app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                    -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                    versions:commit'
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                } 
            }
        }
        stage ("test app") {
             //agent {
                // docker { image 'maven:latest' }
            // }
            steps {
                script {
                    echo "testing app"
                    gv.testPrejar()
                }
            }
        }
        stage("build war") {
            when {
                expression {
                    BRANCH_NAME == 'dev'
                }
            }
             //agent {
                //docker { image 'maven:latest' }
           // }
            steps {
                script {
                    echo "building jar"
                    gv.buildJar()
                }
            }
        }
        stage("build image") {
            when {
                expression {
                    BRANCH_NAME == 'dev'
                }
            }                
            steps {
                script {
                    echo "building image"
                    gv.buildImage()
                }
            }
        }
        stage('provision server') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
                TF_VAR_env_prefix = "${BRANCH_NAME}"
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        stage("deploy") {
            environment {
                DOCKER_CREDS = credentials('dockerhub-credenntials')
            }
            steps {
                script {
                   echo "waiting for EC2 server to initialize" 
                   sleep(time: 100, unit: "SECONDS") 

                   echo 'deploying docker image to EC2...'
                   echo "${EC2_PUBLIC_IP}"

                   def shellCmd = "bash ./serv_cmd.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                   def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"
 
                   sshagent(['server-ec2-user']) {
                       sh "scp -o StrictHostKeyChecking=no serv-cmd.sh ${ec2Instance}:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                   }
                }
            }
            //steps {
                //script {
                   // echo "deploying"
                  //  gv.deployApp()
              //  }
           // }
        }     
        stage('commit update version') {
            when {
                expression {
                    BRANCH_NAME == 'dev'
                }
            }   
            steps {
                script {                    
                    withCredentials([usernamePassword(credentialsId: 'git-token', passwordVariable: 'PASSWD', usernameVariable: 'USER')])
                    {
                        sh "git remote set-url origin https://${PASSWD}@github.com/MargarytaRomanyuk/EPAM_Final_Project.git"
                        sh 'git add .'
                        sh 'git commit -m "CI: version bump" '
                        sh 'git push origin HEAD:dev'
                    }                    
                }
            }
        }
    }
}
