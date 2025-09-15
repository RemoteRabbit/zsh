# Enable startup timing (run 'zsh-benchmark' to see results)
if [[ "$ZSH_BENCHMARK" == "1" ]]; then
  zmodload zsh/zprof
fi

# Source alias files
for file in $ZDOTDIR/alias/*; do
  [[ -r "$file" ]] && [[ -f "$file" ]] && source "$file"
done

# Load additional configuration files if they exist
if [[ -d "$ZDOTDIR/extras" ]]; then
  for file in $ZDOTDIR/extras/*; do
    [[ -r "$file" ]] && [[ -f "$file" ]] && source "$file"
  done
fi

# Load custom keybindings
[[ -r "$ZDOTDIR/keybindings.zsh" ]] && source "$ZDOTDIR/keybindings.zsh"

# Load recovery system
[[ -r "$ZDOTDIR/recovery.zsh" ]] && source "$ZDOTDIR/recovery.zsh"

# Zsh options
setopt autocd autopushd
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

HISTFILE=~/.config/zsh/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Initialize completion system (optimized)
autoload -Uz compinit
# Only regenerate compdump once per day for faster loading
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # Skip security check for faster startup
fi

# Enhanced completion styles
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Oh My Zsh configuration
DISABLE_UPDATE_PROMPT="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Initialize tools (lightweight ones)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Lazy-load heavy tools
_load_atuin() {
  unfunction atuin
  unfunction _load_atuin
  eval "$(atuin init zsh)"
  atuin "$@"
}

_load_carapace() {
  unfunction _load_carapace
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
}

# Create wrapper function for atuin
atuin() { _load_atuin "$@"; }

# Defer carapace loading slightly
if command -v carapace &> /dev/null; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _load_carapace
fi

# macOS-specific setup
if [[ $(uname) == "Darwin" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Initialize Zinit plugin manager
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load plugins with Zinit (fast, automatic updates)
zinit light "zsh-users/zsh-autosuggestions"
zinit light "zsh-users/zsh-syntax-highlighting" 
zinit light "jeffreytse/zsh-vi-mode"

# Auto-suggestions styling
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8,italic'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Optional: Load annexes for additional functionality
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Enable Extended globbing
setopt extended_glob

# Carapace now loaded via lazy-loading above

# Source additional scripts
if [[ -d "$ZDOTDIR/scripts/zsh" ]]; then
    # Use null_glob to prevent errors when no matches
    setopt local_options null_glob
    for file in "$ZDOTDIR/scripts/zsh"/**/*(.); do
        [[ -r "$file" ]] && source "$file"
    done
fi

# Enhanced FZF configuration
export FZF_DEFAULT_OPTS="
  --height=70%
  --layout=reverse
  --border=rounded
  --preview-window=right:60%:wrap
  --bind=ctrl-u:preview-page-up,ctrl-d:preview-page-down
  --bind=ctrl-f:page-down,ctrl-b:page-up
  --color=fg:#f8f8f2,bg:#282a36,hl:#8be9fd
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#50fa7b
  --color=info:#ffb86c,prompt:#ff79c6,pointer:#ff79c6
  --color=marker:#50fa7b,spinner:#ffb86c,header:#6272a4
"

# Smart file finder with ripgrep content preview
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!node_modules/*"'
export FZF_CTRL_T_COMMAND='$FZF_DEFAULT_COMMAND'

# Enhanced file preview with syntax highlighting
export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {} 2>/dev/null || tree -C {} 2>/dev/null'
  --bind 'ctrl-/:toggle-preview'
"

# Enhanced directory search
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --color=always {} | head -200'
"
export EDITOR=nvim
export DOCKER_CMD="podman --storage-opt overlay.ignore_chown_errors=true"
export DOCKER_SOCK=/var/run/docker.sock
export DOCKER_HOST=unix:///var/run/docker.sock
export PNPM_HOME="/home/remoterabbit/.local/share/pnpm"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

# Add PNPM to PATH if not already present
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Add Local bin to PATH
# Add local bin to PATH
export LOCAL_BIN="$HOME/.local/bin"
case ":$PATH:" in
  *":$LOCAL_BIN:"*) ;;
  *) export PATH="$LOCAL_BIN:$PATH" ;;
esac

# Atuin now loaded via lazy-loading above

# Directory-specific configs disabled - using unified setup only

# Show startup benchmark if enabled
if [[ "$ZSH_BENCHMARK" == "1" ]]; then
  echo "Startup time report:"
  zprof | head -20
fi
