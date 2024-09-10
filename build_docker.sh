#!/bin/bash

# Define the path to the secret file
SECRET_FILE="secrets.env"

# Hard-coded Docker repository
DOCKER_REPO="ne0lith/cdl-docker"

# Docker image variant
VARIANT="3.11-alpine"

# Check if the secret file exists
if [ ! -f "$SECRET_FILE" ]; then
    echo "Error: Secret file $SECRET_FILE not found."
    exit 1
fi

# Load the secret from the file
source $SECRET_FILE

# Ensure the WEBHOOK_URL is set in the secrets file
if [ -z "$WEBHOOK_URL" ]; then
    echo "Error: WEBHOOK_URL is not set in $SECRET_FILE."
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
