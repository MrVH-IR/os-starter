#!/usr/bin/env bash

# ============================================================
# CLI Monitoring Tools
#
# Supported:
#   - Fedora
#   - Ubuntu
#
# Tools:
#   - btop
#   - iotop
#   - nload
#   - ncdu
# ============================================================

set -Eeuo pipefail

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

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
# Root Check
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

info "Detected OS: ${PRETTY_NAME}"

# ------------------------------------------------------------
# Packages
# ------------------------------------------------------------

PACKAGES=(
    btop
    iotop
    nload
    ncdu
)

# ------------------------------------------------------------
# Install
# ------------------------------------------------------------

case "$ID" in

    fedora)

        info "Installing monitoring tools..."

        sudo dnf install -y \
            "${PACKAGES[@]}"

        ;;

    ubuntu)

        info "Updating package repositories..."

        sudo apt update

        info "Installing monitoring tools..."

        sudo apt install -y \
            "${PACKAGES[@]}"

        ;;

    *)

        error "Unsupported OS: $ID"
        exit 1

        ;;

esac

# ------------------------------------------------------------
# Verify
# ------------------------------------------------------------

echo

info "Installed tools:"

for package in "${PACKAGES[@]}"; do

    if command -v "$package" >/dev/null 2>&1; then
        echo "  ✓ $package"
    else
        echo "  ✗ $package"
    fi

done

echo

success "Monitoring tools installed successfully."

echo
echo "Usage:"
echo
echo "  btop       # CPU / RAM / Processes"
echo "  iotop      # Disk I/O"
echo "  nload      # Network traffic"
echo "  ncdu /     # Disk usage"
echo
