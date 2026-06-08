# Custom keybindings for enhanced productivity
#
# zsh-vi-mode rebuilds the keymap at the first prompt (zvm_after_init), which
# would wipe any bindkey calls made at source time. So all bindings live in a
# function that is run *after* zvm initializes (with a fallback when the plugin
# isn't loaded). The plugin also enables vi mode, so no `bindkey -v` is needed.

autoload -Uz edit-command-line
zle -N edit-command-line

_apply_custom_keybindings() {
  # Enhanced navigation in vi mode
  bindkey -M vicmd 'H' beginning-of-line
  bindkey -M vicmd 'L' end-of-line
  bindkey -M vicmd 'K' history-beginning-search-backward
  bindkey -M vicmd 'J' history-beginning-search-forward

  # Quick command line editing
  bindkey '^e' edit-command-line
  bindkey '^x^e' edit-command-line

  # Enhanced history search (^r is left to atuin)
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
  bindkey '^w' backward-kill-word
  bindkey '^b' backward-word

  # Enhanced completion navigation
  bindkey '^i' complete-word
  bindkey '^[[Z' reverse-menu-complete  # Shift+Tab

  # Quick reload config
  bindkey -s '^[r' 'source $ZDOTDIR/.zshrc\n'

  # Clear screen but keep scrollback
  bindkey '^l' clear-screen

  # Insert sudo at beginning of line
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

  # Session pickers
  bindkey '^o' sesh-sessions
  bindkey '^[s' sesh-sessions-gum

  # Search in command history with current input
  bindkey '^[[A' history-beginning-search-backward-end  # Up arrow
  bindkey '^[[B' history-beginning-search-forward-end   # Down arrow
}

# Insert sudo at beginning of line
insert_sudo() {
  if [[ $BUFFER != sudo\ * ]]; then
    BUFFER="sudo $BUFFER"
    CURSOR=$(($CURSOR + 5))
  fi
}
zle -N insert_sudo

# Sesh - tmux session picker (works outside tmux)
sesh-sessions() {
  zle -I
  local session
  session=$(sesh list | fzf --no-sort --prompt '⚡ ' \
    --header '^a all ^t tmux ^x zoxide ^g config ^f find' \
    --bind 'ctrl-a:change-prompt(⚡ )+reload(sesh list)' \
    --bind 'ctrl-t:change-prompt(🪟 )+reload(sesh list -t)' \
    --bind 'ctrl-g:change-prompt(⚙️ )+reload(sesh list -c)' \
    --bind 'ctrl-x:change-prompt(📁 )+reload(sesh list -z)' \
    --bind 'ctrl-f:change-prompt(🔎 )+reload(fd -H -d 2 -t d -E .Trash . ~)'
  )
  if [[ -n "$session" ]]; then
    BUFFER="sesh connect \"$session\""
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N sesh-sessions

# Sesh - tmux session picker via gum
sesh-sessions-gum() {
  zle -I
  local session
  session=$(sesh list | gum filter --limit 1 --fuzzy --no-sort \
    --placeholder 'Pick a sesh' --prompt='⚡ '
  )
  if [[ -n "$session" ]]; then
    BUFFER="sesh connect \"$session\""
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N sesh-sessions-gum

# Search in command history with current input
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# zsh-vi-mode rebuilds the keymap at the first prompt, so apply our bindings
# afterward via its hook. Fall back to applying immediately if the plugin isn't
# present.
if (( ${+ZVM_VERSION} )); then
  zvm_after_init_commands+=(_apply_custom_keybindings)
else
  _apply_custom_keybindings
fi
