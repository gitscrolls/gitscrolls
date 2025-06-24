#!/bin/bash

# Shared Docker execution wrapper for GitScrolls hooks
# Ensures consistent Docker execution with verbose output and color support

# Enable verbose mode
set -x

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Default Docker options for all commands
# -t: Allocate a pseudo-TTY for color support
# --rm: Remove container after execution
# -e TERM=xterm-256color: Ensure color support in container
DOCKER_BASE_OPTS="--rm -t -e TERM=xterm-256color"

# Function to run command in Docker with verbose output
docker_run_verbose() {
    local service="$1"
    local command="$2"
    local extra_opts="${3:-}"
    
    echo -e "${YELLOW}🐳 Docker command:${NC}"
    echo "docker compose run $DOCKER_BASE_OPTS $extra_opts $service bash -c \"set -x; $command\""
    
    docker compose run $DOCKER_BASE_OPTS $extra_opts $service bash -c "set -x; $command"
}

# Function to run command in standalone Docker container
docker_run_standalone() {
    local image="$1"
    local command="$2"
    local extra_opts="${3:-}"
    
    echo -e "${YELLOW}🐳 Docker command:${NC}"
    echo "docker run $DOCKER_BASE_OPTS -v $(pwd):/app -w /app $extra_opts $image sh -c \"set -x; $command\""
    
    docker run $DOCKER_BASE_OPTS -v "$(pwd):/app" -w /app $extra_opts $image sh -c "set -x; $command"
}

# Export functions for use in other scripts
export -f docker_run_verbose
export -f docker_run_standalone