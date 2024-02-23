#!/bin/bash

# ./setup.sh com.nyon appium-ios-test

BUNDLE_ID=$1
DOCKER_TAG=$2

echo "Installing USB multiplexing daemon..."
apt install usbmuxd

# Build go-ios tool
echo "Modifying default WDA bundleID 'com.facebook' to $BUNDLE_ID"
directory="go-ios"

# Define the string to search for and the string to replace it with
search_string="com.facebook"

# Use grep to find files containing the search string
files_with_string=$(grep -rl --include="*.go" "$search_string" "$directory")

# Loop through the files found and use sed to replace the string
for file in $files_with_string; do
    sed -i '' -e "s/$search_string/$BUNDLE_ID/g" "$file"
done

./build_ios_tools.sh

echo "Building docker..."
docker build -t $DOCKER_TAG .
echo "Docker build completed!"
docker images | grep $DOCKER_TAG


