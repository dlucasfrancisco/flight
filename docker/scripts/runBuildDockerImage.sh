#!/bin/bash

set -e

readonly declare PROJECTS=("clustersd" "governanced" "eaed")
readonly REGISTRY=globaldevtools.bbva.com:5000/hub/ozqib
readonly DOCKER_FILE_PATH=docker/Dockerfile
readonly DOCKER_BUILD_FLAGS="--no-cache"
readonly USAGE="$(basename "$0") [help] [all/<y-project>] [version] [branch_name] -- Stage which builds the docker image for specific or all projects

where:
    help  show this help text
    all builds all the projects
    <y-project> available projects: $PROJECTS

usage examples:
    make build-docker-image TARGET=help
    make build-docker-image TARGET=epacosd
    make build-docker-image TARGET=all"

readonly TARGET_PROJECT=$1
readonly VERSION=$2
BRANCH=$3

function buildProject() {

    p=$1
    v=$2
    b=$3

    echo "==============: Building docker file for project: $p with version: $v"

    case "$p" in
        all)
            for i in "${PROJECTS[@]}"
            do
               createImage $i $v $b
            done
            ;;
        eaed)
            createImage $p $v $b
            ;;
        governanced)
            createImage $p $v $b
            ;;
        clusterd)
            createImage $p $v $b
            ;;
        *)
            echo "==============: Project not found, please choose one of the next ones: $PROJECTS" >&2
            echo "$USAGE" >&2
            exit 1
            ;;
    esac
}

function createImage() {
    id=$1
    tag=$2
    branch=$3

    if [[ $branch != "master" ]]; then
        tag="feature-${tag}"
    fi

    docker build -f $DOCKER_FILE_PATH -t $REGISTRY/$id:$tag --build-arg PROJECT=$1 $DOCKER_BUILD_FLAGS .
}

if [[ ! -n "$TARGET_PROJECT" ]]; then
    printf "==============: missing argument for %s\n" "[project]" >&2
    echo "$USAGE" >&2
    exit 1
fi

if [[ ! -n "$VERSION" ]]; then
    printf "==============: missing argument for %s\n" "[version]" >&2
    echo "$USAGE" >&2
    exit 1
fi

if [[ ! -n "$BRANCH" ]]; then
    BRANCH=$(git branch | grep \*)
fi

case "$TARGET_PROJECT" in
        help)
            echo "$USAGE"
            ;;
        *)
            buildProject $TARGET_PROJECT $VERSION $BRANCH
            ;;
esac
