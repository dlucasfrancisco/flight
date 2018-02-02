#!/usr/bin/env bash

set -e
readonly CONTAINER_ID_PREFIX=$1

echo "==============: Cleaning containers with prefix: $CONTAINER_ID_PREFIX..."

containers=$(docker ps -a -q --filter "name=$CONTAINER_ID_PREFIX*")

if [ ! -z "$containers" ] ; then
    echo "==============: Cleaning containers: $containers..."
    docker stop $containers || true
    docker rm -f $containers || true
fi

