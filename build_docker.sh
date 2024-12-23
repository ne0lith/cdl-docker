#!/bin/bash

# Load secrets from secrets.env file
if [ -f secrets.env ]; then
    source secrets.env
else
    echo "Error: secrets.env file not found."
    exit 1
fi

# Ensure the DISCORD_WEBHOOK_URL is set from the secrets file
WEBHOOK_URL=${DISCORD_WEBHOOK_URL}

# Hard-coded Docker repository
DOCKER_REPO="ne0lith/cdl-docker"

# Docker image variant
VARIANT="3.11-alpine"

# List of excluded versions
EXCLUDED_VERSIONS=("5.4.70" "5.6.1" "5.7.2.post0" "5.7.2.post1")

# Check if the required environment variable is set
if [ -z "$WEBHOOK_URL" ]; then
    echo "Error: DISCORD_WEBHOOK_URL is not set in secrets.env."
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

# Function to check if a version is excluded
is_version_excluded() {
    local version=$1
    for excluded_version in "${EXCLUDED_VERSIONS[@]}"; do
        if [ "$version" == "$excluded_version" ]; then
            return 0
        fi
    done
    return 1
}

# Retrieve the latest version if version parameter is not provided
if [ -z "$1" ]; then
    VERSION=$(get_latest_version)
else
    VERSION=$1
fi

# Check if the version was retrieved successfully
if [ -z "$VERSION" ]; then
    log "Failed to retrieve the latest version of cyberdrop-dl-patched."
    exit 1
fi

log "Latest version of cyberdrop-dl-patched: $VERSION"

# Check if the version is excluded
if is_version_excluded "$VERSION"; then
    log "Version $VERSION is excluded and will not be built or pushed."
    exit 0
fi

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
