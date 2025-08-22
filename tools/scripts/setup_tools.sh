#!/bin/bash

TOOLS=$@
echo "Tools to install: $TOOLS"

cmd() {
    command -v "$1" > /dev/null 2>&1
}

install_with_snap() {
    if ! cmd "$1"; then
        echo "Installing $1..."
        sudo snap install $1 --classic
    else
        echo "$1 is already installed."
    fi
}

install_with_apt(){
    if ! cmd "$1"; then
        echo "Installing $1..."
        sudo apt install -y "$1"
    else
        echo "$1 is already installed."
    fi
}

for tool in $TOOLS; do
    case "$tool" in
        aws)
            install_with_snap aws
            ;;
        terraform)
            install_with_snap terraform
            ;;
        *)
            echo "$tool is not supported."
            return 1
            ;;
    esac
done
