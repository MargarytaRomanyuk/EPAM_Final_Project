export IMAGE=$1
export DOCKER_USER=$2
export DOCKER_PWD=$3
echo $DOCKER_PWD | docker login -u $DOCKER_USER --password-stdin
docker run -d -p 8080:8080 magharyta/my-repo:${IMAGE_NAME}
echo "Success"