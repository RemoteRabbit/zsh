#!/usr/bin/env bash

# Get the OS name
os_name=$(uname -s)

# Function to check and update Zsh
check_and_update_zsh() {
    # Check if Zsh is installed
    if ! command -v zsh &> /dev/null; then
        echo "Zsh is not installed. Installing Zsh..."
        install_zsh
    else
        echo "Zsh is already installed."

        # Check if Zsh is up-to-date
        current_zsh_version=$(zsh --version | awk '{print $2}')
        latest_zsh_version=$(get_latest_zsh_version)

        if [ "$current_zsh_version" != "$latest_zsh_version" ]; then
            echo "Zsh is not up-to-date. Updating Zsh..."
            install_zsh
        else
            echo "Zsh is up-to-date."
        fi
    fi
}

# Function to get the latest Zsh version
get_latest_zsh_version() {
    if command -v dnf &> /dev/null; then
        dnf info zsh | grep -m1 "Version" | awk '{print $3}'
    elif command -v yum &> /dev/null; then
        yum info zsh | grep -m1 "Version" | awk '{print $3}'
    elif command -v zypper &> /dev/null; then
        zypper info zsh | grep -m1 "Version" | awk '{print $3}'
    elif command -v pacman &> /dev/null; then
        pacman -Si zsh | grep -m1 "Version" | awk '{print $3}'
    else
        echo "Unable to determine the latest Zsh version."
        exit 1
    fi
}

# Function to install Zsh
install_zsh() {
    if command -v dnf &> /dev/null; then
        sudo dnf install -y zsh
    elif command -v yum &> /dev/null; then
        sudo yum install -y zsh
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y --no-confirm zsh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm --needed zsh
    else
        echo "Unable to install Zsh. Unsupported package manager."
        exit 1
    fi
}

# Check the OS name
case "$os_name" in
    Linux*)
        check_and_update_zsh
        ;;
    Darwin*)
        check_and_update_zsh "brew install" "brew info"
        ;;
    *)
        echo "Unsupported operating system: $os_name"
        exit 1
        ;;
esac

# Create symlinks
ln -sf "$HOME/repos/personal/zsh/.zshenv" "$HOME/.zshenv"
mkdir -p "$HOME/.config/zsh"
ln -sf "$HOME/repos/personal/zsh/"* "$HOME/.config/zsh"
ln -sf "$HOME/repos/personal/zsh/.zshrc" "$HOME/.config/zsh/.zshrc"
