# Enable startup timing (run 'zsh-benchmark' to see results)
if [[ "$ZSH_BENCHMARK" == "1" ]]; then
  zmodload zsh/zprof
fi

# Disable terminal flow control so Ctrl+s is available for keybindings
[[ -t 0 ]] && stty -ixon

# Zsh options
setopt autocd autopushd
setopt extended_glob
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
_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n "$_zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"  # Skip security check for faster startup
fi
unset _zcompdump

# Source local configuration after compinit so completion files can use compdef
for file in "$ZDOTDIR"/alias/*(N.); do
  [[ -r "$file" ]] && source "$file"
done

for file in "$ZDOTDIR"/extras/*(N.); do
  [[ -r "$file" ]] && source "$file"
done

[[ -r "$ZDOTDIR/recovery.zsh" ]] && source "$ZDOTDIR/recovery.zsh"

# Enhanced completion styles
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Initialize interactive tools when installed
command -v starship &> /dev/null && eval "$(starship init zsh)"
command -v zoxide &> /dev/null && eval "$(zoxide init zsh)"
command -v atuin &> /dev/null && eval "$(atuin init zsh)"
command -v mise &> /dev/null && eval "$(mise activate zsh)"
command -v direnv &> /dev/null && eval "$(direnv hook zsh)"

# Lazy-load heavier completion generation at the first prompt
_load_carapace() {
  unfunction _load_carapace
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
}

if command -v carapace &> /dev/null; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _load_carapace
fi

# Initialize Zinit plugin manager
if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

if [[ -r "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

  # Vi-mode widgets needed by keybindings load synchronously.
  zinit light "jeffreytse/zsh-vi-mode"

  # Completion and pairing widgets must load after compinit and before highlighters.
  zinit light "Aloxaf/fzf-tab"
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 $realpath'
  AUTOPAIR_INHIBIT_INIT=1
  zinit light "hlissner/zsh-autopair"
  unset AUTOPAIR_INHIBIT_INIT

  # Nonessential plugins load after the first prompt.
  export DEJA_ACCEPT_KEY='^Y'
  export DEJA_CYCLE_KEY=''
  zinit ice wait"0" lucid depth=1
  zinit light "Giammarco-Ferranti/deja"
  zinit ice wait"0" lucid depth=1
  zinit light "akash329d/zsh-alias-finder"
  zinit ice wait"0" lucid depth=1
  zinit light "diverdale/colored-man-pages-plus"
  zstyle ':colored-man:theme' name catppuccin
  zinit ice wait"0" lucid depth=1
  zinit light "zsh-users/zsh-syntax-highlighting"

  # Optional annexes for additional Zinit functionality
  zinit light-mode for \
      zdharma-continuum/zinit-annex-as-monitor \
      zdharma-continuum/zinit-annex-bin-gem-node \
      zdharma-continuum/zinit-annex-patch-dl \
      zdharma-continuum/zinit-annex-rust
fi

# Load custom keybindings after plugins so widgets exist
[[ -r "$ZDOTDIR/keybindings.zsh" ]] && source "$ZDOTDIR/keybindings.zsh"

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
if command -v rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*" --glob "!node_modules/*"'
elif command -v fd &> /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
else
  export FZF_DEFAULT_COMMAND='find . -type f'
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {} 2>/dev/null || tree -C {} 2>/dev/null'
  --bind 'ctrl-/:toggle-preview'
"

export FZF_ALT_C_OPTS="
  --preview 'eza --tree --color=always {} | head -200'
"
export PATH="$HOME/.cargo/bin:$PATH"
export EDITOR=nvim
export DOCKER_CMD="podman --storage-opt overlay.ignore_chown_errors=true"
export DOCKER_SOCK=/var/run/docker.sock
export DOCKER_HOST=unix:///var/run/docker.sock
export PNPM_HOME="$HOME/.local/share/pnpm"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# LuaRocks environment is only needed when invoking Lua tooling.
if (( $+commands[luarocks] )); then
  _load_luarocks() {
    eval "$(command luarocks path)"
    unfunction luarocks
    (( $+functions[lua] )) && unfunction lua
    unfunction _load_luarocks
  }
  luarocks() { _load_luarocks; command luarocks "$@" }
  (( $+commands[lua] )) && lua() { _load_luarocks; command lua "$@" }
fi

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && . "$HOME/.dart-cli-completion/zsh-config.zsh" || true
## [/Completion]

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export LOCAL_BIN="$HOME/.local/bin"
case ":$PATH:" in
  *":$LOCAL_BIN:"*) ;;
  *) export PATH="$LOCAL_BIN:$PATH" ;;
esac

# Show startup benchmark if enabled
if [[ "$ZSH_BENCHMARK" == "1" ]]; then
  echo "Startup time report:"
  zprof | head -20
fi

if command -v tfschema &> /dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C "$(command -v tfschema)" tfschema
fi
