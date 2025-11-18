#!/bin/bash

# Script to install pre-requisites for wordlist generation tool
# Primarily installs GNU Parallel for multi-threaded processing
# Assumes Debian/Ubuntu/Kali (apt-based); detects and handles common distros
# Run as root or with sudo privileges

set -e  # Exit on error

echo "Installing pre-requisites for pentest wordlist generator..."

# Detect package manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    echo "Detected APT-based system (Debian/Ubuntu/Kali)."
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    echo "Detected YUM-based system (RHEL/CentOS)."
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    echo "Detected DNF-based system (Fedora)."
else
    echo "Unsupported package manager. Manual installation required."
    echo "For GNU Parallel: https://www.gnu.org/software/parallel/"
    exit 1
fi

# Install GNU Parallel
case $PKG_MANAGER in
    "apt")
        sudo apt update
        sudo apt install -y parallel
        ;;
    "yum")
        sudo yum update -y
        sudo yum install -y parallel
        ;;
    "dnf")
        sudo dnf update -y
        sudo dnf install -y parallel
        ;;
esac

# Optional: Install pv for progress if piping (common in pentest toolchains)
if command -v apt-get &> /dev/null; then
    sudo apt install -y pv
elif [[ $PKG_MANAGER == "yum" || $PKG_MANAGER == "dnf" ]]; then
    sudo $PKG_MANAGER install -y pv
fi

echo "Installation complete!"
echo "Verify: parallel --version"
echo "Now run your wordlist generator script."
