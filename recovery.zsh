# Zsh configuration recovery and validation system

# Validate configuration before sourcing
validate_config() {
  local config_file="${1:-$ZDOTDIR/.zshrc}"

  if [[ ! -f "$config_file" ]]; then
    echo "❌ Config file not found: $config_file"
    return 1
  fi

  # Test syntax by running in subshell
  if zsh -n "$config_file" 2>/dev/null; then
    echo "✅ Configuration syntax is valid"
    return 0
  else
    echo "❌ Configuration has syntax errors:"
    zsh -n "$config_file"
    return 1
  fi
}

# Create backup before making changes
backup_config() {
  local config_dir="${ZDOTDIR:-$HOME/.config/zsh}"
  local backup_dir="$config_dir/backups/$(date +%Y%m%d_%H%M%S)"

  echo "Creating configuration backup..."
  mkdir -p "$backup_dir"

  # Backup main config files
  for file in .zshrc .zshenv keybindings.zsh; do
    if [[ -f "$config_dir/$file" ]]; then
      cp "$config_dir/$file" "$backup_dir/"
      echo "Backed up: $file"
    fi
  done

  # Backup alias directory
  if [[ -d "$config_dir/alias" ]]; then
    cp -r "$config_dir/alias" "$backup_dir/"
    echo "Backed up: alias directory"
  fi

  echo "Backup created at: $backup_dir"
  echo "$backup_dir" > "$config_dir/.last_backup"
}

# Restore from backup
restore_config() {
  local config_dir="${ZDOTDIR:-$HOME/.config/zsh}"
  local backup_dir

  if [[ $# -eq 0 ]]; then
    # Use last backup
    if [[ -f "$config_dir/.last_backup" ]]; then
      backup_dir=$(cat "$config_dir/.last_backup")
    else
      echo "No backup found. Available backups:"
      ls -la "$config_dir/backups/" 2>/dev/null || echo "No backups directory found"
      return 1
    fi
  else
    backup_dir="$1"
  fi

  if [[ ! -d "$backup_dir" ]]; then
    echo "Backup directory not found: $backup_dir"
    return 1
  fi

  echo "Restoring configuration from: $backup_dir"

  # Restore files
  for file in "$backup_dir"/*; do
    if [[ -f "$file" ]]; then
      local filename=$(basename "$file")
      cp "$file" "$config_dir/$filename"
      echo "Restored: $filename"
    elif [[ -d "$file" ]]; then
      local dirname=$(basename "$file")
      cp -r "$file" "$config_dir/"
      echo "Restored: $dirname directory"
    fi
  done

  echo "Configuration restored successfully"
  echo "Run 'source \$ZDOTDIR/.zshrc' to reload"
}

# Safe config reload with error handling
safe_reload() {
  local config_file="${ZDOTDIR:-$HOME/.config/zsh}/.zshrc"

  echo "Validating configuration..."
  if validate_config "$config_file"; then
    echo "Reloading configuration..."
    source "$config_file"
    echo "✅ Configuration reloaded successfully"
  else
    echo "❌ Configuration has errors. Not reloading."
    echo "Use 'restore_config' to restore from backup or fix the errors manually."
    return 1
  fi
}

# Emergency recovery mode
emergency_recovery() {
  echo "🚨 Emergency Recovery Mode"
  echo "This will reset your zsh configuration to a minimal working state."
  echo ""

  read "response?Continue? This will backup current config first. (y/N): "
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Recovery cancelled."
    return 1
  fi

  # Create backup first
  backup_config

  # Create minimal working config
  local config_dir="${ZDOTDIR:-$HOME/.config/zsh}"
  cat > "$config_dir/.zshrc" << 'EOF'
# Emergency recovery configuration
# Basic zsh setup with minimal functionality

# Basic options
setopt autocd autopushd
setopt extended_history
setopt hist_ignore_dups
setopt share_history

HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

# Basic completion
autoload -Uz compinit && compinit

# Basic aliases
alias ll="ls -la"
alias la="ls -a"
alias ..="cd .."
alias ...="cd ../.."

# Basic environment
export EDITOR=vi
export PATH="$PATH:$HOME/.local/bin"

echo "🚨 Emergency recovery mode active"
echo "Your configuration has been reset to minimal functionality"
echo "Previous configuration backed up and can be restored with 'restore_config'"
EOF

  echo "✅ Emergency configuration created"
  echo "Run 'source \$ZDOTDIR/.zshrc' to activate"
  echo "Use 'restore_config' when ready to restore your full configuration"
}

# Configuration health check
config_health() {
  echo "🔍 Zsh Configuration Health Check"
  echo "================================="

  local config_dir="${ZDOTDIR:-$HOME/.config/zsh}"
  local issues=0

  # Check main config file
  if [[ -f "$config_dir/.zshrc" ]]; then
    echo "✅ Main config file exists"
    if validate_config "$config_dir/.zshrc" >/dev/null 2>&1; then
      echo "✅ Main config syntax is valid"
    else
      echo "❌ Main config has syntax errors"
      ((issues++))
    fi
  else
    echo "❌ Main config file missing"
    ((issues++))
  fi

  # Check keybindings
  if [[ -f "$config_dir/keybindings.zsh" ]]; then
    echo "✅ Keybindings file exists"
  else
    echo "⚠️  Keybindings file missing (optional)"
  fi

  # Check alias directory
  if [[ -d "$config_dir/alias" ]]; then
    echo "✅ Alias directory exists"
    local alias_count=$(ls -1 "$config_dir/alias" | wc -l)
    echo "   Found $alias_count alias files"
  else
    echo "⚠️  Alias directory missing"
  fi

  # Check plugin manager
  if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    echo "✅ Zinit plugin manager installed"
  else
    echo "⚠️  Zinit plugin manager not found"
  fi

  # Check backups
  if [[ -d "$config_dir/backups" ]]; then
    local backup_count=$(ls -1 "$config_dir/backups" 2>/dev/null | wc -l)
    echo "✅ Backup system active ($backup_count backups)"
  else
    echo "⚠️  No backups found"
  fi

  echo ""
  if [[ $issues -eq 0 ]]; then
    echo "🎉 Configuration health: GOOD"
  else
    echo "⚠️  Configuration health: $issues issues found"
    echo "Use 'emergency_recovery' if shell is unstable"
  fi
}

# Clean old backups (keep last 10)
cleanup_backups() {
  local config_dir="${ZDOTDIR:-$HOME/.config/zsh}"
  local backups_dir="$config_dir/backups"

  if [[ ! -d "$backups_dir" ]]; then
    echo "No backups directory found"
    return 0
  fi

  local backup_count=$(ls -1 "$backups_dir" | wc -l)
  if [[ $backup_count -le 10 ]]; then
    echo "Only $backup_count backups found, nothing to clean"
    return 0
  fi

  echo "Found $backup_count backups, keeping latest 10..."
  ls -1t "$backups_dir" | tail -n +11 | while read -r old_backup; do
    rm -rf "$backups_dir/$old_backup"
    echo "Removed old backup: $old_backup"
  done

  echo "Backup cleanup complete"
}
