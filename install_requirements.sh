#!/usr/bin/env bash

# ============================================================
# Developer Desktop Bootstrap
# Supported:
#   - Ubuntu / Debian based
#   - Fedora
#
# This script installs common tools required for a
# developer-friendly Linux desktop environment.
# ============================================================

set -Eeuo pipefail

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ------------------------------------------------------------
# Helper Functions
# ------------------------------------------------------------

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ------------------------------------------------------------
# Check root
# ------------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    error "Do not run this script as root."
    exit 1
fi

# ------------------------------------------------------------
# Detect OS
# ------------------------------------------------------------

if [[ ! -f /etc/os-release ]]; then
    error "/etc/os-release not found."
    exit 1
fi

source /etc/os-release

OS_ID="${ID:-unknown}"

info "Detected OS: ${PRETTY_NAME:-$OS_ID}"

# ------------------------------------------------------------
# Package Manager
# ------------------------------------------------------------

case "$OS_ID" in

    ubuntu|debian)
        PACKAGE_MANAGER="apt"
        ;;

    fedora)
        PACKAGE_MANAGER="dnf"
        ;;

    *)
        error "Unsupported operating system: $OS_ID"
        exit 1
        ;;

esac

# ------------------------------------------------------------
# Package Lists
# ------------------------------------------------------------

COMMON_PACKAGES=(
    sudo
    git
    curl
    wget
    unzip
    zip
    tar
    jq
    tree
    uniq
    tmux
    htop
    btop
    vim
    nano
    openssh-client
    gnupg
    make
    pkg-config
    fzf
    bash-completion
)

# ------------------------------------------------------------
# Ubuntu / Debian Packages
# ------------------------------------------------------------

APT_PACKAGES=(
    "${COMMON_PACKAGES[@]}"
    build-essential
    ripgrep
    fd-find
    bat
)

# ------------------------------------------------------------
# Fedora Packages
# ------------------------------------------------------------

DNF_PACKAGES=(
    "${COMMON_PACKAGES[@]}"
    gcc
    gcc-c++
    ripgrep
    fd-find
    bat
)

# ------------------------------------------------------------
# Update Package Repository
# ------------------------------------------------------------

info "Updating package repositories..."

case "$PACKAGE_MANAGER" in

    apt)
        sudo apt update
        ;;

    dnf)
        sudo dnf makecache
        ;;

esac

# ------------------------------------------------------------
# Install Packages
# ------------------------------------------------------------

info "Installing developer tools..."

case "$PACKAGE_MANAGER" in

    apt)
        sudo apt install -y "${APT_PACKAGES[@]}"
        ;;

    dnf)
        sudo dnf install -y "${DNF_PACKAGES[@]}"
        ;;

esac

success "Base developer tools installed."

# ------------------------------------------------------------
# Enable SSH Agent
# ------------------------------------------------------------

if command -v systemctl >/dev/null 2>&1; then

    info "Enabling SSH agent..."

    systemctl --user enable --now ssh-agent.service \
        2>/dev/null || true

fi


# ------------------------------------------------------------
# Git Configuration Check
# ------------------------------------------------------------

if command -v git >/dev/null 2>&1; then

    if [[ -z "$(git config --global user.name || true)" ]]; then
        warning "Git user.name is not configured."
        echo "Run:"
        echo "  git config --global user.name \"MrVH\""
    fi

    if [[ -z "$(git config --global user.email || true)" ]]; then
        warning "Git user.email is not configured."
        echo "Run:"
        echo "  git config --global user.email \"someEmail@HOTmail.CUM\""
    fi

fi

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

echo
echo "============================================================"
success "Developer desktop setup completed."
echo "============================================================"
echo

echo "Installed package manager : $PACKAGE_MANAGER"
echo "Detected OS               : $PRETTY_NAME"
echo

echo "Next steps:"
echo "  1. Configure Git"
echo "  2. Configure SSH keys"
echo "  3. Install Docker"
echo "  4. Install language runtimes"
echo "  5. Configure shell"
echo
