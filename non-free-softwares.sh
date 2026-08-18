#!/usr/bin/env bash

# ============================================================
# Non-Free / GUI Developer Software Installer
#
# Supported:
#   - Fedora
#   - Ubuntu
#
# Software:
#   - Visual Studio Code
#   - Google Chrome
#   - Postman
#   - DBeaver Community
#
# Usage:
#   ./non-free-softwares.sh
# ============================================================

set -Eeuo pipefail

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ------------------------------------------------------------
# Helpers
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

# ============================================================
# Visual Studio Code
# ============================================================

install_vscode_fedora() {

    info "Installing Visual Studio Code..."

    sudo rpm --import \
        https://packages.microsoft.com/keys/microsoft.asc

    sudo sh -c 'cat > /etc/yum.repos.d/vscode.repo <<EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'

    sudo dnf install -y code

    success "Visual Studio Code installed."
}


install_vscode_ubuntu() {

    info "Installing Visual Studio Code..."

    sudo apt install -y \
        wget \
        gpg \
        apt-transport-https

    wget -qO- \
        https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor \
        | sudo tee /etc/apt/keyrings/packages.microsoft.gpg \
        > /dev/null

    echo \
        "deb [arch=$(dpkg --print-architecture) \
        signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
        https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list \
        > /dev/null

    sudo apt update

    sudo apt install -y code

    success "Visual Studio Code installed."
}


install_vscode() {

    if command -v code >/dev/null 2>&1; then
        success "Visual Studio Code is already installed."
        return
    fi

    case "$OS" in
        fedora)
            install_vscode_fedora
            ;;
        ubuntu)
            install_vscode_ubuntu
            ;;
    esac
}

# ============================================================
# Google Chrome
# ============================================================

install_chrome_fedora() {

    info "Installing Google Chrome..."

    sudo dnf install -y \
        https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

    success "Google Chrome installed."
}


install_chrome_ubuntu() {

    info "Installing Google Chrome..."

    local tmp_file

    tmp_file="/tmp/google-chrome.deb"

    wget -q \
        https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
        -O "$tmp_file"

    sudo apt install -y "$tmp_file"

    rm -f "$tmp_file"

    success "Google Chrome installed."
}


install_chrome() {

    if command -v google-chrome >/dev/null 2>&1 || \
       command -v google-chrome-stable >/dev/null 2>&1; then

        success "Google Chrome is already installed."
        return

    fi

    case "$OS" in
        fedora)
            install_chrome_fedora
            ;;
        ubuntu)
            install_chrome_ubuntu
            ;;
    esac
}

# ============================================================
# Postman
# ============================================================

install_postman() {

    if command -v postman >/dev/null 2>&1; then
        success "Postman is already installed."
        return
    fi

    info "Installing Postman..."

    local tmp_file
    local install_dir

    tmp_file="/tmp/postman.tar.gz"
    install_dir="/opt/Postman"

    wget -q \
        https://dl.pstmn.io/download/latest/linux64 \
        -O "$tmp_file"

    sudo rm -rf "$install_dir"

    sudo tar -xzf "$tmp_file" \
        -C /opt

    rm -f "$tmp_file"

    sudo ln -sf \
        "$install_dir/app/Postman" \
        /usr/local/bin/postman

    success "Postman installed."
}

# ============================================================
# DBeaver
# ============================================================

install_dbeaver_fedora() {

    info "Installing DBeaver..."

    sudo rpm --import \
        https://dbeaver.io/debs/dbeaver.gpg.key

    sudo dnf install -y \
        https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm

    success "DBeaver installed."
}


install_dbeaver_ubuntu() {

    info "Installing DBeaver..."

    sudo apt install -y \
        wget \
        apt-transport-https

    wget -q \
        https://dbeaver.io/files/dbeaver.gpg.key \
        -O /tmp/dbeaver.gpg.key

    sudo gpg \
        --dearmor \
        --yes \
        -o /etc/apt/keyrings/dbeaver.gpg \
        /tmp/dbeaver.gpg.key

    echo \
        "deb [signed-by=/etc/apt/keyrings/dbeaver.gpg] \
        https://dbeaver.io/debs/dbeaver-ce /" \
        | sudo tee /etc/apt/sources.list.d/dbeaver.list \
        > /dev/null

    sudo apt update

    sudo apt install -y dbeaver-ce

    rm -f /tmp/dbeaver.gpg.key

    success "DBeaver installed."
}


install_dbeaver() {

    if command -v dbeaver >/dev/null 2>&1; then
        success "DBeaver is already installed."
        return
    fi

    case "$OS" in
        fedora)
            install_dbeaver_fedora
            ;;
        ubuntu)
            install_dbeaver_ubuntu
            ;;
    esac
}

# ============================================================
# Main
# ============================================================

echo
echo "============================================================"
echo "       Non-Free / GUI Developer Software"
echo "============================================================"
echo

info "Installing Visual Studio Code..."
install_vscode

echo

info "Installing Google Chrome..."
install_chrome

echo

info "Installing Postman..."
install_postman

echo

info "Installing DBeaver..."
install_dbeaver

echo
echo "============================================================"
success "All selected software has been installed."
echo "============================================================"
