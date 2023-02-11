def testPrejar() {
    echo "Testing the application..."
    sh 'mvn test'
}

def buildJar() {
    echo "Building the application..."
    sh 'mvn clean package -DskipTests'
} 

def buildImage() {
    echo "Building the docker image..."
   withCredentials([usernamePassword(credentialsId: 'dockerhub-credenntials', passwordVariable: 'PASSWD', usernameVariable: 'USER')]) {
       sh 'docker build -t magharyta/my-repo:${IMAGE_NAME} .'
       sh "echo $PASSWD | docker login -u $USER --password-stdin"
       sh 'docker push magharyta/my-repo:${IMAGE_NAME}'
    }
} 

def deployApp() {
    echo 'Deploying the application...'
} 

return this
