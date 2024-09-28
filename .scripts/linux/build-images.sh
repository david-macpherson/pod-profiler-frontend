#!/bin/bash

set -e

# Check if $USERNAME exists
if [ -z "$USERNAME" ]; then

    # Set $USERNAME to $USER
    USERNAME=$USER
fi

####################################################
#####  Global varaiables
####################################################

CWD=`pwd`

REGISTRY=registry.internal.tensor.works
REPO="sps-"$USERNAME
VERSION="0.0.0-devel"

FRONTEND_IMAGE=pod-profiler-frontend
FRONTEND_DOCKERFILE=.dockerfiles/pod-profiler-frontend.dockerfile

BUILD_FRONTEND=false

BUILD_ACTION_COMPILE_TYPESCRIPT=true
BUILD_ACTION_COMPILE_GOLANG=true
BUILD_ACTION_CONTAINER_BUILD=true
BUILD_ACTION_CONTAINER_PUSH=true
BUILD_ACTION_DELETE_POD=false

####################################################
#####  Flags
####################################################

while test $# -gt 0; do
  case "$1" in

    # custom version
    --version)
        shift
        VERSION=$1
        shift
    ;;
    --repo)
        shift
        REPO=$1
        shift
    ;;
    --registry)
        shift
        REGISTRY=$1
        shift
    ;;
    --skip-compile)
        BUILD_ACTION_COMPILE_TYPESCRIPT=false
        BUILD_ACTION_COMPILE_GOLANG=false
        shift
    ;;
    --skip-build)
        BUILD_ACTION_CONTAINER_BUILD=false
        shift
    ;;
    --skip-push)
        BUILD_ACTION_CONTAINER_PUSH=false
        shift
    ;;
    --frontend)
        BUILD_FRONTEND=true
        shift
    ;;
    --dockerhub)
        REGISTRY="docker.io"
        REPO="tensorworks"
        shift
    ;;
    --pod-del)
        BUILD_ACTION_DELETE_POD=true
        shift
    ;;
    --all)
        BUILD_FRONTEND=true
        shift
    ;;
    *)
        break
        ;;
  esac
done

####################################################
#####  Computed variables
####################################################

FRONTEND_TAG=$REGISTRY/$REPO/$FRONTEND_IMAGE:$VERSION

####################################################
#####  Variable dump
####################################################

echo "=====  Build variables  ====="

echo "------ Globals-------"
echo "REGISTRY:               $REGISTRY"
echo "REPO:                   $REPO"
echo "VERSION:                $VERSION"
echo ""

echo "----- Container -----"
echo "FRONTEND_IMAGE:         $FRONTEND_IMAGE"
echo ""

echo "------ Building ------"
echo "FRONTEND:               $BUILD_FRONTEND"
echo ""

echo "------ Actions ------"
echo "COMPILE GOLANG:         $BUILD_ACTION_COMPILE_GOLANG"
echo "COMPILE TYPESCRIPT:     $BUILD_ACTION_COMPILE_TYPESCRIPT"
echo "BUILD CONTAINER:        $BUILD_ACTION_CONTAINER_BUILD"
echo "PUSH  CONTAINER:        $BUILD_ACTION_CONTAINER_PUSH"
echo "DELETE POD:             $BUILD_ACTION_DELETE_POD"
echo ""
echo "-------------------------"
echo ""

echo "FRONTEND TAG:           $FRONTEND_TAG"
echo "======================="

####################################################
#####  Functions
####################################################

# This will Build a container
#   $1 - Container Tag
#   $2 - Docker File
#   $3 - Docker build additional arguments
#   $4 - Docker build additional arguments
#   $5 - Docker build additional arguments
function build_container(){
    TAG=$1
    DOCKER_FILE=$2

    if [ "$BUILD_ACTION_CONTAINER_BUILD" == "true" ]; then
        echo ""
        echo "Building Container " $TAG $DOCKER_FILE
        echo ""
        docker build --tag $TAG --file $DOCKER_FILE $3 $4 $5 $6 $7 $8 .
    fi
}

# This will push the container to the registry
#   $1 - Container Tag
function push_container(){
    TAG=$1

    if [ "$BUILD_ACTION_CONTAINER_PUSH" == "true" ]; then
        docker push $TAG
    fi
}

# Generates and compiles the typescript source code using npm
function compile_typescript(){
    # Check if we're compiling the typescript frontend
    if [ "$BUILD_ACTION_COMPILE_TYPESCRIPT" == "true" ]; then

        echo "Building frontend source..."

        # Install all package dependicies
        npm install

        # Build the files
        npm run build

    fi
}

# Builds and pushes the container. Uses dockerignore file and takes a string that lists all files to omit from the ignore
#   $1 - Container tag
#   $2 - Dockerfile
#   $3 - A list of files to omit from dockerignore as a relative path from the repo root (e.g. '\n!bin/linux/amd64/server\n!bin/linux/amd64/server')
function build_push(){
    TAG=$1
    DOCKERFILE=$2
    OMIT_IGNORE=$3

    # Create a docker ignore file
    echo -e "*!$OMIT_IGNORE" > .dockerignore

    # Build the container
    build_container $TAG $DOCKERFILE

    # Clean up the docker ignore file
    rm -rf .dockerignore

    # Push the container
    push_container $TAG
}

####################################################
#####  Main
####################################################

# Build the frontend
if [ "$BUILD_FRONTEND" == "true" ]; then
    compile_typescript
    build_push $FRONTEND_TAG $FRONTEND_DOCKERFILE "\n!dist"
fi


if [ "$BUILD_ACTION_DELETE_POD" == true ]; then
   
    POD_PREFIX_NAMES=()
    
    if [ "$BUILD_FRONTEND" == true ]; then 
        POD_PREFIX_NAMES+=($FRONTEND_IMAGE)
    fi 

    echo ""
    echo "Getting Pod to delete"

    for POD_PREFIX_NAME in ${POD_PREFIX_NAMES[@]}; do

        echo $POD_PREFIX_NAME
        echo "Deleteing pod with prefix ${POD_PREFIX_NAME}"

        POD_NAME=`kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ${POD_PREFIX_NAME}`
        kubectl delete pod $POD_NAME

        echo ""
    done
fi
