#!/bin/bash

# ./setup.sh com.nyon.WebDriverAgentRunner appium-ios-test

BUNDLE_ID=$1
DOCKER_TAG=$2

echo "Installing USB multiplexing daemon..."
apt install usbmuxd

# Build go-ios tool
echo "Modifying default WDA bundleID to $BUNDLE_ID"
# TODO: Testing sed command
# sed -i "s/com.facebook.WebDriverAgentRunner/$BUNDLE_ID/g" go-ios/main.go
./build_ios_tools.sh

echo "Building docker..."
docker build -t $DOCKER_TAG .
echo "Docker build completed!"
docker images | grep $DOCKER_TAG


