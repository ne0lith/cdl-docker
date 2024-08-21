#!/bin/bash

# Set your DISCORD webhook URL here:
# export DISCORD_WEBHOOK_URL="https://your-webhook-url.com"
WEBHOOK_URL=${DISCORD_WEBHOOK_URL}

# Hard-coded Docker repository
DOCKER_REPO="ne0lith/cdl-docker"

# Check if the required environment variable is set
if [ -z "$WEBHOOK_URL" ]; then
    echo "Error: DISCORD_WEBHOOK_URL environment variable is not set."
    exit 1
fi

# Ensure the Docker repository is defined
if [ -z "$DOCKER_REPO" ]; then
    echo "Error: DOCKER_REPO is not set."
    exit 1
fi

# Function to prepend timestamp to our logs
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to send a message via Discord webhook
send_discord_notification() {
    local message=$1
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" $WEBHOOK_URL
}

# Function to retrieve the latest version of the package from PyPI
get_latest_version() {
    curl -s https://pypi.org/pypi/cyberdrop-dl-patched/json | jq -r '.info.version'
}

# Function to check if the image exists on Docker Hub
image_exists_on_dockerhub() {
    local tag=$1
    curl -s "https://hub.docker.com/v2/repositories/$DOCKER_REPO/tags/$tag/" | jq -r '.name' 2>/dev/null
}

# Retrieve the latest version
VERSION=$(get_latest_version)

# Check if the version was retrieved successfully
if [ -z "$VERSION" ]; then
    log "Failed to retrieve the latest version of cyberdrop-dl-patched."
    exit 1
fi

log "Latest version of cyberdrop-dl-patched: $VERSION"

# Check if the image with this version already exists on Docker Hub
if [ "$(image_exists_on_dockerhub $VERSION)" == "$VERSION" ]; then
    log "Docker image for version $VERSION already exists on Docker Hub. No need to rebuild."
    exit 0
fi

log "Building Docker image for version $VERSION..."

# Build the Docker image with the specified version
docker build --build-arg CYBERDROP_DL_VERSION=$VERSION -t $DOCKER_REPO:$VERSION .

# Check if the image was built successfully
if [ $? -eq 0 ]; then
    log "Docker image built and tagged as $DOCKER_REPO:$VERSION"
else
    log "Failed to build the Docker image."
    exit 1
fi

# Push the version-specific tag to the Docker repository
docker push $DOCKER_REPO:$VERSION

# Check if the push was successful
if [ $? -eq 0 ]; then
    log "Docker image pushed as $DOCKER_REPO:$VERSION"
    send_discord_notification "Docker image $DOCKER_REPO:$VERSION has been successfully pushed."
else
    log "Failed to push the Docker image."
    exit 1
fi

# Tag the image as latest
docker tag $DOCKER_REPO:$VERSION $DOCKER_REPO:latest

# Push the latest tag to the Docker repository
docker push $DOCKER_REPO:latest

# Check if the push was successful
if [ $? -eq 0 ]; then
    log "Docker image pushed as $DOCKER_REPO:latest"
    send_discord_notification "Docker image $DOCKER_REPO:latest has been successfully pushed."
else
    log "Failed to push the Docker image as latest."
    exit 1
fi
