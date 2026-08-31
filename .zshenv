ZDOTDIR=$HOME/.config/zsh

# Homebrew environment without running `brew shellenv` during every startup
if [[ -d /opt/homebrew ]]; then
  HOMEBREW_PREFIX=/opt/homebrew
elif [[ -d /usr/local/Homebrew ]]; then
  HOMEBREW_PREFIX=/usr/local
elif [[ -d /home/linuxbrew/.linuxbrew ]]; then
  HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
fi

if [[ -n "$HOMEBREW_PREFIX" ]]; then
  export HOMEBREW_PREFIX
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
  export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
  export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH:+:$MANPATH}"
  export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
fi
