#!/usr/bin/env bash

# ============================================================
# Java Development Environment
#
# Supported:
#   - Fedora
#   - Ubuntu
#
# Java versions:
#   - 17 LTS
#   - 21 LTS
#   - 25 LTS
# ============================================================

set -Eeuo pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

DEFAULT_JAVA_VERSION="21"

JAVA_VERSIONS=(
    17
    21
    25
)

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# ------------------------------------------------------------
# Install Java - Fedora
# ------------------------------------------------------------

install_java_fedora() {

    local version="$1"

    info "Installing OpenJDK ${version}..."

    sudo dnf install -y \
        "java-${version}-openjdk-devel"

    success "OpenJDK ${version} installed."
}

# ------------------------------------------------------------
# Install Java - Ubuntu
# ------------------------------------------------------------

install_java_ubuntu() {

    local version="$1"

    info "Installing OpenJDK ${version}..."

    sudo apt update

    sudo apt install -y \
        "openjdk-${version}-jdk"

    success "OpenJDK ${version} installed."
}

# ------------------------------------------------------------
# Install All Java Versions
# ------------------------------------------------------------

for version in "${JAVA_VERSIONS[@]}"; do

    case "$OS" in

        fedora)
            install_java_fedora "$version"
            ;;

        ubuntu)
            install_java_ubuntu "$version"
            ;;

    esac

done

# ------------------------------------------------------------
# Select Default Java
# ------------------------------------------------------------

info "Selecting Java ${DEFAULT_JAVA_VERSION} as default..."

if command -v alternatives >/dev/null 2>&1; then

    sudo alternatives --set java \
        "/usr/lib/jvm/java-${DEFAULT_JAVA_VERSION}-openjdk/bin/java" \
        2>/dev/null || true

    sudo alternatives --set javac \
        "/usr/lib/jvm/java-${DEFAULT_JAVA_VERSION}-openjdk/bin/javac" \
        2>/dev/null || true

else

    sudo update-alternatives \
        --set java \
        "/usr/lib/jvm/java-${DEFAULT_JAVA_VERSION}-openjdk-amd64/bin/java" \
        2>/dev/null || true

    sudo update-alternatives \
        --set javac \
        "/usr/lib/jvm/java-${DEFAULT_JAVA_VERSION}-openjdk-amd64/bin/javac" \
        2>/dev/null || true

fi

# ------------------------------------------------------------
# Verify
# ------------------------------------------------------------

echo

info "Current Java version:"

java -version

echo

info "Available Java versions:"

if [[ "$OS" == "fedora" ]]; then
    alternatives --display java 2>/dev/null || true
else
    update-alternatives --list java 2>/dev/null || true
fi

echo

success "Java development environment is ready."

echo
echo "To switch Java version:"
echo

if [[ "$OS" == "fedora" ]]; then
    echo "  sudo alternatives --config java"
else
    echo "  sudo update-alternatives --config java"
fi

echo
