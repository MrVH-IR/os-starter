#!/usr/bin/env bash

# ============================================================
# PHP Development Environment
#
# Supported:
#   - Fedora
#   - Ubuntu
#
# Fedora:
#   Uses Remi Repository
#
# Ubuntu:
#   Uses Ondrej PHP PPA
#
# Default PHP version:
#   8.4
#
# Supported versions:
#   Fedora: 8.2, 8.3, 8.4, 8.5
#   Ubuntu: 8.2, 8.3, 8.4
# ============================================================

set -Eeuo pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

DEFAULT_PHP_VERSION="8.4"

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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
# Fedora
# ------------------------------------------------------------

install_php_fedora() {

    info "Preparing Fedora for PHP development..."

    # Install repository management tools
    sudo dnf install -y \
        dnf-plugins-core \
        https://rpms.remirepo.net/fedora/remi-release-${VERSION_ID}.rpm

    success "Remi repository installed."

    # --------------------------------------------------------
    # Reset existing PHP module
    # --------------------------------------------------------

    info "Resetting PHP module..."

    sudo dnf module reset php -y

    # --------------------------------------------------------
    # Enable PHP version
    # --------------------------------------------------------

    info "Enabling PHP ${DEFAULT_PHP_VERSION}..."

    sudo dnf module enable \
        "php:remi-${DEFAULT_PHP_VERSION}" \
        -y

    # --------------------------------------------------------
    # Install PHP
    # --------------------------------------------------------

    info "Installing PHP ${DEFAULT_PHP_VERSION}..."

    sudo dnf install -y \
        php \
        php-cli \
        php-fpm \
        php-common \
        php-mysqlnd \
        php-pdo \
        php-gd \
        php-mbstring \
        php-curl \
        php-xml \
        php-zip \
        php-bcmath \
        php-intl \
        php-opcache \
        php-readline \
        php-process \
        php-soap

    success "PHP ${DEFAULT_PHP_VERSION} installed."

    # --------------------------------------------------------
    # Enable PHP-FPM
    # --------------------------------------------------------

    info "Enabling PHP-FPM..."

    sudo systemctl enable --now php-fpm

    success "PHP-FPM is running."
}

# ------------------------------------------------------------
# Ubuntu
# ------------------------------------------------------------

install_php_ubuntu() {

    info "Preparing Ubuntu for PHP development..."

    # --------------------------------------------------------
    # Dependencies
    # --------------------------------------------------------

    sudo apt update

    sudo apt install -y \
        software-properties-common \
        ca-certificates \
        lsb-release \
        apt-transport-https

    # --------------------------------------------------------
    # Add Ondrej PHP PPA
    # --------------------------------------------------------

    if ! grep -Rqs "^deb .*ppa.launchpadcontent.net/ondrej/php" \
        /etc/apt/sources.list \
        /etc/apt/sources.list.d/ 2>/dev/null; then

        info "Adding Ondrej PHP repository..."

        sudo add-apt-repository ppa:ondrej/php -y

    else

        success "Ondrej PHP repository already exists."

    fi

    sudo apt update

    # --------------------------------------------------------
    # Install PHP
    # --------------------------------------------------------

    info "Installing PHP ${DEFAULT_PHP_VERSION}..."

    sudo apt install -y \
        "php${DEFAULT_PHP_VERSION}" \
        "php${DEFAULT_PHP_VERSION}-cli" \
        "php${DEFAULT_PHP_VERSION}-fpm" \
        "php${DEFAULT_PHP_VERSION}-mysql" \
        "php${DEFAULT_PHP_VERSION}-pdo" \
        "php${DEFAULT_PHP_VERSION}-gd" \
        "php${DEFAULT_PHP_VERSION}-mbstring" \
        "php${DEFAULT_PHP_VERSION}-curl" \
        "php${DEFAULT_PHP_VERSION}-xml" \
        "php${DEFAULT_PHP_VERSION}-zip" \
        "php${DEFAULT_PHP_VERSION}-bcmath" \
        "php${DEFAULT_PHP_VERSION}-intl" \
        "php${DEFAULT_PHP_VERSION}-opcache" \
        "php${DEFAULT_PHP_VERSION}-readline" \
        "php${DEFAULT_PHP_VERSION}-soap"

    success "PHP ${DEFAULT_PHP_VERSION} installed."

    # --------------------------------------------------------
    # Enable PHP-FPM
    # --------------------------------------------------------

    sudo systemctl enable --now \
        "php${DEFAULT_PHP_VERSION}-fpm"

    success "PHP-FPM is running."
}

# ------------------------------------------------------------
# OS Selection
# ------------------------------------------------------------

case "$ID" in

    fedora)
        install_php_fedora
        ;;

    ubuntu)
        install_php_ubuntu
        ;;

    *)
        error "Unsupported OS: $ID"
        exit 1
        ;;

esac

# ------------------------------------------------------------
# PHP Version
# ------------------------------------------------------------

echo
info "PHP version:"

php -v

echo

# ------------------------------------------------------------
# PHP Modules
# ------------------------------------------------------------

info "Installed PHP extensions:"

php -m

echo

success "PHP development environment is ready."
