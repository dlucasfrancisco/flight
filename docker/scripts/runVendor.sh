#!/bin/bash

set -e

echo "==============: Removing vendor cache..."
rm -rf .glide
rm -rf vendor

echo "==============: Creating folders..."
mkdir vendor
mkdir .glide

echo "==============: Installing vendor..."
glide install
glide update

echo "==============: Changing permissions..."
chmod -R 777 vendor
chmod -R 777 .glide