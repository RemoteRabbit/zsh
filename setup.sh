#!/usr/bin/env bash

# Get the directory where this script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

        # Let package manager handle updates (more reliable than parsing versions)
        if command -v brew &> /dev/null; then
            echo "Upgrading Zsh via Homebrew..."
            brew upgrade zsh 2>/dev/null || echo "Zsh is up-to-date."
        elif command -v pacman &> /dev/null; then
            echo "Updating Zsh via pacman..."
            sudo pacman -S --noconfirm --needed zsh
        elif command -v dnf &> /dev/null; then
            echo "Updating Zsh via dnf..."
            sudo dnf upgrade -y zsh
        elif command -v apt &> /dev/null; then
            echo "Updating Zsh via apt..."
            sudo apt update && sudo apt install -y --only-upgrade zsh
        else
            echo "No supported package manager found; skipping Zsh update."
        fi
    fi
}

# Function to install Zsh
install_zsh() {
    if command -v brew &> /dev/null; then
        brew install zsh
    elif command -v dnf &> /dev/null; then
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
                tools="eza bat git-delta ripgrep fd starship zoxide atuin shellcheck"
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

    # Prefer package manager, then pip
    case "$os_name" in
        Darwin*)
            if command -v brew &> /dev/null; then
                brew install pre-commit
                echo "✅ pre-commit installed via Homebrew"
                return
            fi
            ;;
        Linux*)
            if command -v pacman &> /dev/null; then
                sudo pacman -S --noconfirm --needed pre-commit
                echo "✅ pre-commit installed via pacman"
                return
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y pre-commit
                echo "✅ pre-commit installed via dnf"
                return
            elif command -v apt &> /dev/null; then
                sudo apt install -y pre-commit
                echo "✅ pre-commit installed via apt"
                return
            fi
            ;;
    esac

    # Fallback to pip
    if command -v pip3 &> /dev/null; then
        pip3 install --user pre-commit
        echo "✅ pre-commit installed via pip3"

        # Check if pre-commit is in PATH, warn if not
        if ! command -v pre-commit &> /dev/null; then
            user_base="$(python3 -m site --user-base 2>/dev/null || echo "$HOME/.local")"
            echo "⚠️  pre-commit installed but not in PATH"
            echo "   Add $user_base/bin to your PATH to use it"
        fi
    elif command -v pip &> /dev/null; then
        pip install --user pre-commit
        echo "✅ pre-commit installed via pip"

        # Check if pre-commit is in PATH, warn if not
        if ! command -v pre-commit &> /dev/null; then
            user_base="$(python -m site --user-base 2>/dev/null || echo "$HOME/.local")"
            echo "⚠️  pre-commit installed but not in PATH"
            echo "   Add $user_base/bin to your PATH to use it"
        fi
    else
        echo "⚠️  Could not install pre-commit automatically"
        echo "   Please install manually: pip install pre-commit"
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
        check_and_update_zsh
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
ln -sf "$script_dir/.zshenv" "$HOME/.zshenv"
ln -sf "$script_dir" "$HOME/.config/zsh"

# Install Zinit plugin manager
echo "Installing Zinit plugin manager..."
if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    # Ensure git is available
    if ! command -v git &> /dev/null; then
        echo "⚠️  Git is required to install Zinit. Please install git first."
        exit 1
    fi

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
    cd "$script_dir" || exit 1

    # Only install hooks if this is a git repository
    if [[ -d ".git" ]]; then
        pre-commit install
        pre-commit install --hook-type commit-msg
    else
        echo "⚠️  Not a git repository, skipping pre-commit hook installation"
    fi

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
