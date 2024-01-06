# # Used to check optimization
# zmodload zsh/zprof
# zmodload zsh/datetime
# setopt promptsubst
# PS4='+$EPOCHREALTIME %N:%i> '
# exec 3>&2 2> $ZDOTDIR/stats/startlog.$$
# setopt xtrace prompt_subst
# -----------------------------------------
# # Tmux start or attach
# if [ ! "$TMUX" ]; then
#   tmux new-session -s dots -d -c $HOME/dot_files
#   tmux attach -t home || tmux new-session -s home -c $HOME
# fi

for file in $ZDOTDIR/alias/*; do
  source $file
done

# Plugin for not needing to use cd and better tab completion
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

pfetch

# # Used to check optimization
# unsetopt xtrace
# exec 2>&3 3>&-
# zprof > $ZDOTDIR/stats/zprof-stats
