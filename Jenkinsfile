pipeline {
    agent any
    tools {
        maven 'maven-3.8'
    }
    //parameters{
      //  booleanParam(name: 'destroyEnv', defaultValue: false, description: 'Destroy test environment by terraform')
    //}
    stages {
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
                    echo "Testing the application..."
                    sh 'mvn test'
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
                    echo "Building the application..."
                    sh 'mvn clean package -DskipTests'
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
                    echo "Building the docker image..."
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credenntials', passwordVariable: 'PASSWD', usernameVariable: 'USER')]) {
                        sh 'docker build -t magharyta/my-repo:${IMAGE_NAME} .'
                        sh "echo $PASSWD | docker login -u $USER --password-stdin"
                        sh 'docker push magharyta/my-repo:${IMAGE_NAME}'
                        sh 'docker rmi magharyta/my-repo:${IMAGE_NAME}'
                    }
                }
            }
        }
        stage("provision web-server for deploy") {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_access_secret_key_id')
                TF_VAR_env_prefix = "${BRANCH_NAME}"
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init -no-color"
                        sh "terraform apply --auto-approve -no-color"
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
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
                       sh "scp -o StrictHostKeyChecking=no serv_cmd.sh ${ec2Instance}:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                   }
                }
            }
        } 
        stage("approve/disallow to destroy env") {
            //when {
              //  expression {
                //    params.destroyEnv == true
                //}
           // }
            steps {
                script {
                    def destroyOptions = 'no\nyes'
                    def userInput = input(
                        id: 'userInput', message: 'Are you prepared to destroy environment?', parameters: [ 
                        [$class: 'ChoiceParameterDefinition', choices: destroyOptions, description: 'Approve/Disallow env destroy', name: 'destroy-check']
                        ]
                    )
                    env.USER_INPUT = "$userInput"
                    echo "you selected: ${userInput}"
                }
            }
        }
        stage("destroy env") {
            when {
                expression { env.USER_INPUT == 'yes' } // destroy approved      
                }
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_access_secret_key_id')
                TF_VAR_env_prefix = "${BRANCH_NAME}"
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init -no-color"
                        sh "terraform destroy --auto-approve -no-color"
                    }
                }
            }
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
