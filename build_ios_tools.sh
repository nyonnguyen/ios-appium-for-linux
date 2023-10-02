#!/bin/bash
echo "Building go-ios ..."
cd go-ios

echo "Build go-ios binary for MacOS..."
export GOOS=darwin 
export GOARCH=amd64 
go build -o bin/app-amd64-darwin
cp bin/app-amd64-darwin ../ios-mac

echo "Build go-ios binary for Linux..."
export GOOS=linux 
export GOARCH=amd64 
go build -o bin/app-amd64-linux
cp bin/app-amd64-linux ../ios-linux

echo "Build go-ios binary for Windows..."
export GOOS=windows 
export GOARCH=386 
go build -o bin/app-386.exe
cp bin/app-386.exe ../ios-win

echo "Done!"
