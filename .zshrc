for file in $ZDOTDIR/alias/*; do
  source $file
done

source $ZDOTDIR/sourcegraph

setopt  autocd autopushd
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

DISABLE_UPDATE_PROMPT="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

if [[ $(uname) == "Darwin" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Plugins
for dir in $ZDOTDIR/shell-plugins/*; do
  name=$(basename $dir)
  source $dir/$name.zsh
done

for file in $ZDOTDIR/scripts/zsh/*; do
  source $file
done

# Exports
export FZF_DEFAULT_OPTS='--height=70% --preview="cat {}" --preview-window=right:60%:wrap'
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_CTRL_T_COMMAND='$FZF_DEFAULT_COMMAND'
export EDITOR=nvim

export PNPM_HOME="/home/remoterabbit/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

if [[ $(uname) == "Darwin" ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi
