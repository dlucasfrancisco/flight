#!/bin/bash

set -e

echo "==============: Removing cache..."
rm -rf .glide
rm -rf vendor
rm -rf bin

echo "==============: Creating folders..."
mkdir vendor
mkdir .glide
mkdir bin

echo "==============: Install glide dependencies..."
glide install

echo "==============: Build parameters..."
buildTime=$(date -u +%s)
commitHash=$(git rev-parse HEAD)
version="v1.0"
ldflags="-X main.commitHash=$commitHash -X main.buildTime=$buildTime -X main.version=$version"

echo "==============: Build Cluster CLI App..."
GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "$ldflags" -o bin/flight-linux ./cmd/cli
GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build -ldflags "$ldflags" -o bin/flight-darwin ./cmd/cli

ln bin/flight-linux bin/flight

echo "==============: Changing permissions..."
chmod -R 777 vendor
chmod -R 777 .glide
chmod -R 777 bin