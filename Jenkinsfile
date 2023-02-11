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
            //agent {
                 //docker { image 'maven:latest' }
            // }
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
        stage("build jar") {
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
            //agent any
            steps {
                script {
                    echo "building image"
                    gv.buildImage()
                }
            }
        }
        stage("deploy") {  
            when {
                expression {
                    BRANCH_NAME == 'main'
                }
            }
            steps {
                script {
                    echo "deploying"
                    gv.deployApp()
                }
            }
        }     
        stage('commit update version') {
            //agent any
            steps {
                script {                    
                    withCredentials([usernamePassword(credentialsId: 'git-token', passwordVariable: 'PASSWD', usernameVariable: 'USER')])
                    {
                        sh 'git config --list'
                        sh "git remote set-url origin https://${PASSWD}@github.com/MargarytaRomanyuk/Java-maven-app.git"
                        sh 'git add .'
                        sh 'git commit -m "CI: version bump" '
                        sh 'git push origin HEAD:dev'
                    }                    
                }
            }
        }
    }
}
