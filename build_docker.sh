#!/bin/bash

# Function to retrieve the latest version of the package from PyPI
get_latest_version() {
    curl -s https://pypi.org/pypi/cyberdrop-dl-patched/json | jq -r '.info.version'
}

# Function to check if the image exists on Docker Hub
image_exists_on_dockerhub() {
    curl -s "https://hub.docker.com/v2/repositories/ne0lith/cdl-docker/tags/$1/" | jq -r '.name' 2>/dev/null
}

# Retrieve the latest version
VERSION=$(get_latest_version)

# Check if the version was retrieved successfully
if [ -z "$VERSION" ]; then
    echo "Failed to retrieve the latest version of cyberdrop-dl-patched."
    exit 1
fi

echo "Latest version of cyberdrop-dl-patched: $VERSION"

# Check if the image with this version already exists on Docker Hub
if [ "$(image_exists_on_dockerhub $VERSION)" == "$VERSION" ]; then
    echo "Docker image for version $VERSION already exists on Docker Hub. No need to rebuild."
    exit 0
fi

echo "Building Docker image for version $VERSION..."

# Build the Docker image with the specified version
docker build --build-arg CYBERDROP_DL_VERSION=$VERSION -t ne0lith/cdl-docker:$VERSION .

# Check if the image was built successfully
if [ $? -eq 0 ]; then
    echo "Docker image built and tagged as ne0lith/cdl-docker:$VERSION"
else
    echo "Failed to build the Docker image."
    exit 1
fi

# Push the version-specific tag to the Docker repository
docker push ne0lith/cdl-docker:$VERSION

# Check if the push was successful
if [ $? -eq 0 ]; then
    echo "Docker image pushed as ne0lith/cdl-docker:$VERSION"
else
    echo "Failed to push the Docker image."
    exit 1
fi

# Tag the image as latest
docker tag ne0lith/cdl-docker:$VERSION ne0lith/cdl-docker:latest

# Push the latest tag to the Docker repository
docker push ne0lith/cdl-docker:latest

# Check if the push was successful
if [ $? -eq 0 ]; then
    echo "Docker image pushed as ne0lith/cdl-docker:latest"
else
    echo "Failed to push the Docker image as latest."
    exit 1
fi
