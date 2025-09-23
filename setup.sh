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
    elif command -v apt &> /dev/null; then
        apt-cache policy zsh | grep -m1 "Candidate:" | awk '{print $2}'
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
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y zsh
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y --no-confirm zsh
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm --needed zsh
    else
        echo "Unable to install Zsh. Unsupported package manager."
        exit 1
    fi
}

# Function to install modern shell tools
install_modern_tools() {
    echo "Installing modern shell tools..."

    local tools
    case "$os_name" in
        Linux*)
            if command -v brew &> /dev/null; then
                # Use Homebrew on Linux if available
                tools="eza bat git-delta ripgrep fd starship zoxide atuin shellcheck"
                # shellcheck disable=SC2086
                brew install $tools
            elif command -v pacman &> /dev/null; then
                tools="eza bat delta ripgrep fd starship zoxide atuin shellcheck"
                # shellcheck disable=SC2086
                sudo pacman -S --noconfirm --needed $tools
            elif command -v dnf &> /dev/null; then
                tools="eza bat git-delta ripgrep fd-find starship zoxide atuin ShellCheck"
                # shellcheck disable=SC2086
                sudo dnf install -y $tools
            elif command -v apt &> /dev/null; then
                tools="bat ripgrep fd-find shellcheck"
                # shellcheck disable=SC2086
                sudo apt update && sudo apt install -y $tools
                echo "Note: eza, delta, starship, zoxide, and atuin may need manual installation on Debian/Ubuntu"
                echo "      Consider installing Homebrew for Linux to get all tools: https://brew.sh/"
            elif command -v zypper &> /dev/null; then
                tools="bat ripgrep fd starship zoxide ShellCheck"
                # shellcheck disable=SC2086
                sudo zypper install -y --no-confirm $tools
                echo "Note: eza, delta, and atuin may need manual installation on SUSE"
            else
                echo "Note: Modern tools may need manual installation on your system"
                echo "      Consider installing Homebrew for Linux: https://brew.sh/"
            fi
            ;;
        Darwin*)
            if command -v brew &> /dev/null; then
                tools="eza bat git-delta ripgrep fd starship zoxide atuin shellcheck"
                # shellcheck disable=SC2086
                brew install $tools
            else
                echo "Homebrew not found. Please install it first."
            fi
            ;;
    esac
}

# Function to install pre-commit
install_precommit() {
    echo "Installing pre-commit..."

    # Try pip first, then package manager
    if command -v pip3 &> /dev/null; then
        pip3 install --user pre-commit
        echo "✅ pre-commit installed via pip3"
    elif command -v pip &> /dev/null; then
        pip install --user pre-commit
        echo "✅ pre-commit installed via pip"
    else
        case "$os_name" in
            Linux*)
                if command -v pacman &> /dev/null; then
                    sudo pacman -S --noconfirm --needed pre-commit
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y pre-commit
                elif command -v apt &> /dev/null; then
                    sudo apt install -y pre-commit
                else
                    echo "⚠️  Could not install pre-commit automatically"
                    echo "   Please install manually: pip install pre-commit"
                fi
                ;;
            Darwin*)
                if command -v brew &> /dev/null; then
                    brew install pre-commit
                else
                    echo "⚠️  Could not install pre-commit automatically"
                    echo "   Please install manually: pip install pre-commit"
                fi
                ;;
        esac
    fi
}

# Check the OS name and install tools
case "$os_name" in
    Linux*)
        check_and_update_zsh
        install_modern_tools
        install_precommit
        ;;
    Darwin*)
        check_and_update_zsh "brew install" "brew info"
        install_modern_tools
        install_precommit
        ;;
    *)
        echo "Unsupported operating system: $os_name"
        exit 1
        ;;
esac

# Create symlinks with backup
echo "Setting up Zsh configuration..."

# Backup existing files
backup_dir="$HOME/.config/zsh_backup_$(date +%Y%m%d_%H%M%S)"
if [[ -f "$HOME/.zshenv" ]] || [[ -d "$HOME/.config/zsh" ]]; then
    echo "Backing up existing configuration to $backup_dir"
    mkdir -p "$backup_dir"
    [[ -f "$HOME/.zshenv" ]] && mv "$HOME/.zshenv" "$backup_dir/"
    [[ -d "$HOME/.config/zsh" ]] && mv "$HOME/.config/zsh" "$backup_dir/"
fi

# Create directory and symlinks
mkdir -p "$HOME/.config"
ln -sf "$HOME/repos/personal/zsh/.zshenv" "$HOME/.zshenv"
ln -sf "$HOME/repos/personal/zsh" "$HOME/.config/zsh"

# Install Zinit plugin manager
echo "Installing Zinit plugin manager..."
if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone --depth=1 https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
    echo "Zinit installed successfully!"
else
    echo "Zinit already installed."
fi

# Compile zsh files for faster loading
if command -v zsh &> /dev/null; then
    echo "Compiling Zsh configuration files..."
    zsh -c "autoload -U zrecompile && zrecompile -p $HOME/.config/zsh/.zshrc" 2>/dev/null || true
fi

# Install plugins with Zinit
if command -v zsh &> /dev/null && [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    echo "Installing Zsh plugins..."
    zsh -c '
        source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
        zinit light "zsh-users/zsh-autosuggestions"
        zinit light "zsh-users/zsh-syntax-highlighting"
        zinit light "jeffreytse/zsh-vi-mode"
        echo "Plugins installed successfully!"
    ' 2>/dev/null || echo "Plugin installation will happen on first shell startup."
fi

# Setup pre-commit hooks
if command -v pre-commit &> /dev/null; then
    echo "Setting up pre-commit hooks..."
    cd "$HOME/repos/personal/zsh" || exit 1
    pre-commit install
    pre-commit install --hook-type commit-msg

    # Initialize secrets baseline
    if command -v detect-secrets &> /dev/null; then
        detect-secrets scan --baseline .secrets.baseline 2>/dev/null || true
    fi

    echo "✅ Pre-commit hooks installed successfully!"
    echo "   Run 'pre-commit run --all-files' to test all hooks"
else
    echo "⚠️  Pre-commit not available, skipping hook installation"
fi

echo "🎉 Zsh setup complete!"
echo "📋 What was installed:"
echo "  • Zsh shell and modern tools (eza, bat, delta, etc.)"
echo "  • Zinit plugin manager with 3 essential plugins"
echo "  • Optimized configuration with lazy-loading"
echo ""
echo "🚀 To start using: restart your terminal or run 'source ~/.zshenv'"
