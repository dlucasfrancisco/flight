#!/bin/bash

set -e

echo "==============: Removing cache..."
rm -rf mocks

echo "==============: Creating folders..."
mkdir mocks

echo "==============: Install dependencies..."
go get github.com/vektra/mockery/.../

echo "==============: Build mocks..."
go generate ./pkg/...

echo "==============: Changing permissions..."
chmod -R 777 mocks