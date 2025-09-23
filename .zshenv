ZDOTDIR=$HOME/.config/zsh
if [[ $(uname) == "Darwin" ]]; then
  # Support both Apple Silicon and Intel Mac paths
  if [[ -d /opt/homebrew ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  elif [[ -d /usr/local/Homebrew ]]; then
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
  fi
fi
