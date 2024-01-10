for file in $ZDOTDIR/alias/*; do
  source $file
done

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

if [[ $(uname) == "Darwin" ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi

pfetch
