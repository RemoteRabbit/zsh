# Custom keybindings for enhanced productivity

# Enable vi mode keybindings (if zsh-vi-mode plugin isn't handling this)
bindkey -v

# Enhanced navigation in vi mode
bindkey -M vicmd 'H' beginning-of-line
bindkey -M vicmd 'L' end-of-line
bindkey -M vicmd 'K' history-beginning-search-backward
bindkey -M vicmd 'J' history-beginning-search-forward

# Quick command line editing
bindkey '^e' edit-command-line
bindkey '^x^e' edit-command-line

# Enhanced history search
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Quick directory navigation
bindkey -s '^f' 'f\n'  # Quick file finder
bindkey -s '^j' 'j\n'  # Quick directory jumper
bindkey -s '^g' 'search '  # Quick content search

# Command line utilities
bindkey '^u' backward-kill-line
bindkey '^k' kill-line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^w' backward-kill-word
bindkey '^b' backward-word
bindkey '^f' forward-word

# Enhanced completion navigation
bindkey '^i' complete-word
bindkey '^[[Z' reverse-menu-complete  # Shift+Tab

# Quick reload config
bindkey -s '^[r' 'source $ZDOTDIR/.zshrc\n'

# Clear screen but keep scrollback
bindkey '^l' clear-screen

# Insert sudo at beginning of line
insert_sudo() {
  if [[ $BUFFER != sudo\ * ]]; then
    BUFFER="sudo $BUFFER"
    CURSOR=$(($CURSOR + 5))
  fi
}
zle -N insert_sudo
bindkey '^s^u' insert_sudo

# Quick git status
bindkey -s '^g^s' 'gs\n'

# Toggle between insert and command mode quickly
bindkey -M viins 'jj' vi-cmd-mode
bindkey -M viins 'jk' vi-cmd-mode

# Better undo/redo in vi mode
bindkey -M vicmd 'u' undo
bindkey -M vicmd '^r' redo

# Partial command completion
bindkey '^[[1;5D' backward-word    # Ctrl+Left
bindkey '^[[1;5C' forward-word     # Ctrl+Right

# Auto-suggestion accept
bindkey '^y' autosuggest-accept
bindkey '^[[1;5F' autosuggest-accept  # Ctrl+End

# Search in command history with current input
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A' history-beginning-search-backward-end  # Up arrow
bindkey '^[[B' history-beginning-search-forward-end   # Down arrow
