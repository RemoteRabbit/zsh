# 🐚 Advanced Zsh Configuration

A highly optimized, modular Zsh configuration focused on productivity, performance, and ease of use. Features modern tools integration, intelligent plugin management, and comprehensive error recovery.

## ✨ Features

### 🚀 Performance Optimized
- **Lazy-loading** for generated completions and nonessential plugins
- **Compiled configs** with zcompile for faster startup
- **Smart completion** system with daily cache refresh
- **Startup benchmarking** tools to monitor performance

### 🛠 Modern Tools Integration
- **eza** - Modern `ls` replacement with icons and git integration
- **bat** - Syntax-highlighted file viewer (`view` command)
- **ripgrep** - Lightning-fast search (`grep` replacement)
- **fd** - User-friendly `find` alternative
- **fzf** - Fuzzy finder with enhanced previews and keybindings
- **starship** - Fast, customizable prompt
- **zoxide** - Smart directory jumping
- **atuin** - Enhanced shell history
- **mise** - Project tool versions and tasks
- **direnv** - Per-directory environment activation

### 📦 Plugin Management
- **Zinit** plugin manager for fast, automatic updates
- **Essential plugins**: Deja suggestions, fzf-tab, autopair, syntax highlighting, vi-mode
- **Workflow plugins**: alias finder and colored man pages
- **One-command updates**: `zinit update`

### 🔧 Productivity Features
- **Enhanced navigation** - Smart directory jumping, bookmarks
- **Git integration** - Comprehensive aliases and interactive log
- **Search functions** - Content search with preview, history search
- **Process management** - Interactive process finder/killer
- **Note taking** - Quick note system with daily files
- **Archive management** - Smart extract/compress functions

### 🚑 Error Recovery & Validation
- **Config health checks** - Validate syntax and dependencies
- **Automatic backups** - Timestamped config backups before changes
- **Emergency recovery** - Minimal config fallback if things break
- **Safe reload** - Test config before applying

### 🔍 Quality Assurance & Development
- **Pre-commit hooks** - Automated code quality checks before commits
- **Shell script linting** - ShellCheck integration for script validation
- **Markdown formatting** - Automatic documentation formatting
- **Security scanning** - Detect secrets and security issues
- **Syntax validation** - Zsh syntax checking for all configuration files

### 📚 Built-in Help System
- **Interactive help** - `zsh-help` command with categories
- **Function discovery** - `list-functions` shows available tools
- **Random tips** - `tips` command for learning new features

## 🚀 Quick Start

### Installation
```bash
# Clone the repository
git clone https://github.com/remoterabbit/zsh.git ~/repos/personal/zsh

# Run the setup script
cd ~/repos/personal/zsh
./setup.sh

# Restart your terminal or reload
source ~/.zshenv
```

The setup script will:
1. Install Zsh and modern tools (eza, bat, ripgrep, etc.)
2. Install Zinit plugin manager
3. Download and configure plugins
4. Create proper symlinks to your config
5. Compile configs for optimal performance

### First Steps
```bash
# Check configuration health
config-health

# Get help on available features
zsh-help

# Test performance
zsh-benchmark

# Try some features
j           # Interactive directory jumper
search      # Search file contents with preview
h           # Interactive history search
```

## 📁 Configuration Structure

```
zsh/
├── .zshrc              # Main configuration file
├── .zshenv             # Environment variables
├── keybindings.zsh     # Custom key bindings
├── recovery.zsh        # Error recovery system
├── setup.sh            # Automated setup script
├── cleanup.sh          # Configuration cleanup and optimization
├── alias/              # Modular alias files
│   ├── core            # Basic aliases and modern tool integration
│   ├── git             # Git aliases and functions
│   ├── navigation      # Directory navigation helpers
│   ├── productivity    # Productivity functions
│   ├── fzf-enhancements # Enhanced FZF functions
│   ├── benchmark       # Performance testing
│   └── help            # Built-in help system
├── README.md           # This file
└── CONFIGURATION.md    # Detailed configuration documentation
```

## 🎯 Key Commands & Functions

### Navigation
- `goto-work`, `goto-personal`, `goto-open` - Jump to repo directories with listing
- `repos`, `work`, `config` - Zoxide shortcuts for common paths
- `j` - Interactive directory jumper using fzf
- `take <dir>` - Create directory and cd into it
- `..`, `...`, `....` - Quick parent directory navigation

### Search & Discovery
- `search <pattern>` - Search file contents with syntax-highlighted preview
- `f` - Interactive file finder with actions (edit, copy, delete)
- `h [pattern]` - Interactive history search or pattern search
- `env-search` - Browse environment variables with fzf

### Git Integration
- `g*` - Comprehensive git aliases (gs, ga, gc, gl, gd, etc.)
- `glog` - Interactive git log with commit preview
- `gcheck` - Quick repository status overview

### Productivity
- `pgrep <pattern>` - Search processes with highlighting
- `pkill` - Interactive process killer (fzf-powered)
- `pkill-pattern <pattern>` - Kill processes by pattern with confirmation
- `backup <file>` - Create timestamped backup
- `archive <src> <dest>` - Smart archive creation (tar.gz, zip)
- `extract <archive>` - Smart archive extraction
- `sysinfo` - System information summary
- `weather [city]` - Get weather information
- `m`, `mr`, `mx` - Mise, run a task, or execute with managed tools
- `da`, `dr` - Allow or reload the current direnv environment

### Configuration Management
- `config-health` - Check configuration health
- `backup_config` - Create configuration backup
- `restore_config` - Restore from backup
- `safe_reload` - Safely reload configuration
- `emergency_recovery` - Reset to minimal working config

### Performance
- `zsh-benchmark` - Comprehensive startup time analysis
- `zsh-time` - Quick startup time check
- `zsh-profile` - Profile current session

### Help & Discovery
- `zsh-help [category]` - Comprehensive help system
- `list-functions` - Show available custom functions
- `tips` - Random productivity tips
- `help <function>` - Quick function help

## ⌨️ Key Bindings

### Navigation
- `Ctrl+F` - Quick file finder
- `Ctrl+J` - Quick directory jumper
- `Ctrl+G` - Start content search

### History & Editing
- `Ctrl+R` - Interactive history search
- `Ctrl+Y` - Accept Deja suggestion
- `Tab` - Fuzzy completion with fzf-tab
- `Ctrl+E` - Edit command in editor
- `Alt+R` - Reload configuration

### Vi Mode Enhancements
- `jj`, `jk` - Exit insert mode
- `H`, `L` - Beginning/end of line in command mode
- `K`, `J` - History search in command mode

### FZF Integration
- `Ctrl+/` - Toggle preview in fzf
- `Ctrl+U/D` - Preview page up/down
- `Ctrl+F/B` - Page navigation

## 🔧 Customization

### Adding Aliases
Create new files in `alias/` directory:
```bash
# alias/custom
alias myalias="my command"

my_function() {
  echo "Custom function"
}
```

### Custom Configuration
Add your personal customizations to the `alias/` files or create new ones:
```bash
# alias/custom
export MY_VAR="value"
alias mycommand="echo hello"
```

### Adding Plugins
Edit `.zshrc` and add zinit lines:
```bash
zinit light "user/plugin-name"
```

### Environment Variables
Add to `.zshenv` for login shell variables or `.zshrc` for interactive shell variables.

## 🚑 Recovery & Troubleshooting

### Configuration Issues
```bash
# Check configuration health
config-health

# Validate configuration syntax
validate_config

# Create backup before changes
backup_config

# Emergency reset if config is broken
emergency_recovery
```

### Performance Issues
```bash
# Benchmark startup time
zsh-benchmark

# Profile what's slowing down startup
ZSH_BENCHMARK=1 zsh

# Clean up old backups
cleanup_backups
```

### Plugin Issues
```bash
# Update all plugins
zinit update

# Reinstall specific plugin
zinit delete user/plugin-name
zinit load user/plugin-name

# List installed plugins
zinit list
```

## 📊 Performance

Typical startup times:
- **Cold start**: ~100-150ms
- **Warm start**: ~50-80ms
- **With benchmarking**: ~200ms (includes profiling overhead)

Performance optimizations:
- Lazy-loading of heavy tools (atuin, carapace)
- Compiled configuration files
- Smart completion caching
- Async plugin loading with Zinit

## 📚 Documentation

- **[README.md](README.md)** - Getting started and overview
- **[CONFIGURATION.md](CONFIGURATION.md)** - Detailed configuration documentation
- **Built-in help** - Run `zsh-help` for interactive help system

## 🧹 Maintenance

### Regular Maintenance
```bash
./cleanup.sh         # Clean backups, optimize performance
config-health        # Check configuration health
zsh-benchmark        # Monitor performance
zinit update         # Update plugins
```

### Development & Quality Assurance
```bash
pre-commit run --all-files  # Run all quality checks
pre-commit install          # Install git hooks
shellcheck *.sh             # Lint shell scripts
zsh -n .zshrc               # Validate zsh syntax
```

### Troubleshooting
```bash
emergency_recovery   # Reset to minimal working config
restore_config       # Restore from backup
validate_config      # Check syntax
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes with `config-health` and `zsh-benchmark`
4. Run `./cleanup.sh` to optimize
5. Submit a pull request

## 📝 License

Unlicense - This is free and unencumbered software released into the public domain.

## 🙏 Acknowledgments

Built with these excellent tools:
- [Zinit](https://github.com/zdharma-continuum/zinit) - Plugin manager
- [Starship](https://starship.rs/) - Prompt
- [eza](https://github.com/eza-community/eza) - Modern ls
- [bat](https://github.com/sharkdp/bat) - Better cat
- [ripgrep](https://github.com/BurntSushi/ripgrep) - Fast search
- [fd](https://github.com/sharkdp/fd) - Better find
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [zoxide](https://github.com/ajeetdsouza/zoxide) - Smart cd
- [atuin](https://github.com/atuinsh/atuin) - Shell history

---

**Enjoy your supercharged Zsh experience!** 🚀

For questions or issues, run `zsh-help` or check the [configuration health](#-recovery--troubleshooting).
