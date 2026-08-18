#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# Docker Installation Script
#
# Supported:
#   - Fedora
#   - Ubuntu
#
# Installs:
#   - Docker Engine
#   - Docker CLI
#   - Docker Compose Plugin
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ------------------------------------------------------------
# Root check
# ------------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    error "Do not run this script as root."
    exit 1
fi

# ------------------------------------------------------------
# Detect OS
# ------------------------------------------------------------

if [[ ! -f /etc/os-release ]]; then
    error "Cannot detect operating system."
    exit 1
fi

source /etc/os-release

case "$ID" in
    fedora)
        OS="fedora"
        ;;

    ubuntu)
        OS="ubuntu"
        ;;

    *)
        error "Unsupported OS: $ID"
        exit 1
        ;;
esac

info "Detected OS: ${PRETTY_NAME}"

# ------------------------------------------------------------
# Install Docker
# ------------------------------------------------------------

if command -v docker >/dev/null 2>&1; then
    success "Docker is already installed."
else

    info "Installing Docker..."

    case "$OS" in

        fedora)

            sudo dnf -y install dnf-plugins-core

            sudo dnf config-manager \
                --add-repo \
                https://download.docker.com/linux/fedora/docker-ce.repo

            sudo dnf install -y \
                docker-ce \
                docker-ce-cli \
                containerd.io \
                docker-buildx-plugin \
                docker-compose-plugin

            ;;

        ubuntu)

            sudo apt update

            sudo apt install -y \
                ca-certificates \
                curl \
                gnupg

            sudo install -m 0755 -d /etc/apt/keyrings

            curl -fsSL \
                https://download.docker.com/linux/ubuntu/gpg \
                | sudo gpg --dearmor \
                -o /etc/apt/keyrings/docker.gpg

            sudo chmod a+r /etc/apt/keyrings/docker.gpg

            echo \
                "deb [arch=$(dpkg --print-architecture) \
                signed-by=/etc/apt/keyrings/docker.gpg] \
                https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
                | sudo tee /etc/apt/sources.list.d/docker.list \
                > /dev/null

            sudo apt update

            sudo apt install -y \
                docker-ce \
                docker-ce-cli \
                containerd.io \
                docker-buildx-plugin \
                docker-compose-plugin

            ;;

    esac

fi

# ------------------------------------------------------------
# Enable Docker service
# ------------------------------------------------------------

info "Enabling Docker service..."

sudo systemctl enable --now docker

# ------------------------------------------------------------
# Add current user to docker group
# ------------------------------------------------------------

if groups "$USER" | grep -q '\bdocker\b'; then

    success "User '$USER' is already in docker group."

else

    info "Adding '$USER' to docker group..."

    sudo usermod -aG docker "$USER"

    success "User added to docker group."

    echo
    echo "You need to log out and log in again"
    echo "or run:"
    echo
    echo "    newgrp docker"
    echo

fi

# ------------------------------------------------------------
# Verify installation
# ------------------------------------------------------------

echo

docker --version || true
docker compose version || true

echo

success "Docker installation completed."
