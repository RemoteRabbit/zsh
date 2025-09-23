#!/usr/bin/env bash

# Zsh Configuration Cleanup Script
# Removes backup files, temporary data, and optimizes configuration

set -euo pipefail

CONFIG_DIR="${ZDOTDIR:-$HOME/.config/zsh}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧹 Zsh Configuration Cleanup"
echo "============================"

# Function to ask for confirmation
confirm() {
    local prompt="$1"
    local response
    read -r -p "$prompt (y/N): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

# Clean backup directories
cleanup_backups() {
    echo "📁 Cleaning backup directories..."

    if [[ -d "$CONFIG_DIR/backups" ]]; then
        local backup_count
        backup_count=$(find "$CONFIG_DIR/backups" -maxdepth 1 -type d ! -path "$CONFIG_DIR/backups" | wc -l)
        if [[ $backup_count -gt 0 ]]; then
            echo "Found $backup_count backup directories"
            if confirm "Remove all backups except the 3 most recent?"; then
                # Keep only the 3 most recent backups
                find "$CONFIG_DIR/backups" -maxdepth 1 -type d ! -path "$CONFIG_DIR/backups" -printf '%T@ %p\n' | sort -rn | tail -n +4 | cut -d' ' -f2- | while read -r old_backup; do
                    rm -rf "$CONFIG_DIR/backups/$old_backup"
                    echo "Removed: $old_backup"
                done
                echo "✅ Backup cleanup complete"
            fi
        else
            echo "No backups found"
        fi
    else
        echo "No backup directory found"
    fi
}

# Clean shell-plugins.backup if present
cleanup_old_plugins() {
    echo "🔌 Cleaning old plugin directories..."

    if [[ -d "$REPO_DIR/shell-plugins.backup" ]]; then
        if confirm "Remove old shell-plugins.backup directory?"; then
            rm -rf "$REPO_DIR/shell-plugins.backup"
            echo "✅ Removed shell-plugins.backup"
        fi
    else
        echo "No old plugin directories found"
    fi
}

# Clean compiled files and regenerate
recompile_configs() {
    echo "⚙️  Recompiling configuration files..."

    # Remove existing compiled files
    find "$CONFIG_DIR" -name "*.zwc" -type f -delete 2>/dev/null || true
    find "$REPO_DIR" -name "*.zwc" -type f -delete 2>/dev/null || true

    # Recompile main configuration
    if command -v zsh &>/dev/null; then
        zsh -c "
            autoload -U zrecompile
            zrecompile -p '$CONFIG_DIR/.zshrc'
            zrecompile -p '$CONFIG_DIR/keybindings.zsh'
            zrecompile -p '$CONFIG_DIR/recovery.zsh'
        " 2>/dev/null || echo "⚠️  Some files couldn't be compiled"
        echo "✅ Configuration files recompiled"
    else
        echo "⚠️  Zsh not available for recompilation"
    fi
}

# Clean completion cache
clean_completion_cache() {
    echo "🔄 Cleaning completion cache..."

    local cache_files=(
        "$HOME/.zcompdump"
        "$HOME/.zcompdump.zwc"
        "$CONFIG_DIR/.zcompdump"
        "$CONFIG_DIR/.zcompdump.zwc"
    )

    local cleaned=0
    for cache_file in "${cache_files[@]}"; do
        if [[ -f "$cache_file" ]]; then
            rm -f "$cache_file"
            echo "Removed: $(basename "$cache_file")"
            ((cleaned++))
        fi
    done

    if [[ $cleaned -gt 0 ]]; then
        echo "✅ Cleaned $cleaned cache files"
    else
        echo "No cache files found"
    fi
}

# Optimize Zinit
optimize_zinit() {
    echo "⚡ Optimizing Zinit..."

    if [[ -d "$HOME/.local/share/zinit" ]]; then
        if command -v zsh &>/dev/null; then
            echo "Updating Zinit and plugins..."
            zsh -c "
                source '$HOME/.local/share/zinit/zinit.git/zinit.zsh'
                zinit self-update
                zinit update --all
                zinit compile --all
            " 2>/dev/null || echo "⚠️  Some Zinit operations failed"
            echo "✅ Zinit optimized"
        else
            echo "⚠️  Zsh not available for Zinit optimization"
        fi
    else
        echo "Zinit not found"
    fi
}

# Validate configuration
validate_config() {
    echo "✅ Validating configuration..."

    if command -v zsh &>/dev/null; then
        if zsh -n "$CONFIG_DIR/.zshrc" 2>/dev/null; then
            echo "✅ Configuration syntax is valid"
        else
            echo "❌ Configuration has syntax errors:"
            zsh -n "$CONFIG_DIR/.zshrc"
            return 1
        fi
    else
        echo "⚠️  Zsh not available for validation"
    fi
}

# Main execution
main() {
    echo "Configuration directory: $CONFIG_DIR"
    echo "Repository directory: $REPO_DIR"
    echo ""

    # Run cleanup operations
    cleanup_backups
    echo ""

    cleanup_old_plugins
    echo ""

    clean_completion_cache
    echo ""

    recompile_configs
    echo ""

    optimize_zinit
    echo ""

    validate_config
    echo ""

    echo "🎉 Cleanup complete!"
    echo ""
    echo "💡 Recommendations:"
    echo "   • Restart your terminal to apply changes"
    echo "   • Run 'zsh-benchmark' to check performance"
    echo "   • Run 'config-health' to verify everything works"
}

# Check if running from the correct directory
if [[ ! -f "$REPO_DIR/.zshrc" ]]; then
    echo "❌ Error: This script must be run from the zsh configuration directory"
    echo "Expected to find .zshrc in: $REPO_DIR"
    exit 1
fi

# Run main function
main "$@"
