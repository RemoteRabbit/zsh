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
eval "$(atuin init zsh)"

# Lazy-load heavy tools

_load_carapace() {
  unfunction _load_carapace
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
}



# Defer carapace loading slightly
if command -v carapace &> /dev/null; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _load_carapace
fi

# Homebrew setup
if [[ $(uname) == "Darwin" ]]; then
  # macOS Homebrew
  export PATH="/opt/homebrew/bin:$PATH"
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ $(uname) == "Linux" ]] && command -v brew &> /dev/null; then
  # Linux Homebrew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
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


#compdef databricks
compdef _databricks databricks

# zsh completion for databricks                           -*- shell-script -*-

__databricks_debug()
{
    local file="$BASH_COMP_DEBUG_FILE"
    if [[ -n ${file} ]]; then
        echo "$*" >> "${file}"
    fi
}

_databricks()
{
    local shellCompDirectiveError=1
    local shellCompDirectiveNoSpace=2
    local shellCompDirectiveNoFileComp=4
    local shellCompDirectiveFilterFileExt=8
    local shellCompDirectiveFilterDirs=16
    local shellCompDirectiveKeepOrder=32

    local lastParam lastChar flagPrefix requestComp out directive comp lastComp noSpace keepOrder
    local -a completions

    __databricks_debug "\n========= starting completion logic =========="
    __databricks_debug "CURRENT: ${CURRENT}, words[*]: ${words[*]}"

    # The user could have moved the cursor backwards on the command-line.
    # We need to trigger completion from the $CURRENT location, so we need
    # to truncate the command-line ($words) up to the $CURRENT location.
    # (We cannot use $CURSOR as its value does not work when a command is an alias.)
    words=("${=words[1,CURRENT]}")
    __databricks_debug "Truncated words[*]: ${words[*]},"

    lastParam=${words[-1]}
    lastChar=${lastParam[-1]}
    __databricks_debug "lastParam: ${lastParam}, lastChar: ${lastChar}"

    # For zsh, when completing a flag with an = (e.g., databricks -n=<TAB>)
    # completions must be prefixed with the flag
    setopt local_options BASH_REMATCH
    if [[ "${lastParam}" =~ '-.*=' ]]; then
        # We are dealing with a flag with an =
        flagPrefix="-P ${BASH_REMATCH}"
    fi

    # Prepare the command to obtain completions
    requestComp="${words[1]} __complete ${words[2,-1]}"
    if [ "${lastChar}" = "" ]; then
        # If the last parameter is complete (there is a space following it)
        # We add an extra empty parameter so we can indicate this to the go completion code.
        __databricks_debug "Adding extra empty parameter"
        requestComp="${requestComp} \"\""
    fi

    __databricks_debug "About to call: eval ${requestComp}"

    # Use eval to handle any environment variables and such
    out=$(eval ${requestComp} 2>/dev/null)
    __databricks_debug "completion output: ${out}"

    # Extract the directive integer following a : from the last line
    local lastLine
    while IFS='\n' read -r line; do
        lastLine=${line}
    done < <(printf "%s\n" "${out[@]}")
    __databricks_debug "last line: ${lastLine}"

    if [ "${lastLine[1]}" = : ]; then
        directive=${lastLine[2,-1]}
        # Remove the directive including the : and the newline
        local suffix
        (( suffix=${#lastLine}+2))
        out=${out[1,-$suffix]}
    else
        # There is no directive specified.  Leave $out as is.
        __databricks_debug "No directive found.  Setting do default"
        directive=0
    fi

    __databricks_debug "directive: ${directive}"
    __databricks_debug "completions: ${out}"
    __databricks_debug "flagPrefix: ${flagPrefix}"

    if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
        __databricks_debug "Completion received error. Ignoring completions."
        return
    fi

    local activeHelpMarker="_activeHelp_ "
    local endIndex=${#activeHelpMarker}
    local startIndex=$((${#activeHelpMarker}+1))
    local hasActiveHelp=0
    while IFS='\n' read -r comp; do
        # Check if this is an activeHelp statement (i.e., prefixed with $activeHelpMarker)
        if [ "${comp[1,$endIndex]}" = "$activeHelpMarker" ];then
            __databricks_debug "ActiveHelp found: $comp"
            comp="${comp[$startIndex,-1]}"
            if [ -n "$comp" ]; then
                compadd -x "${comp}"
                __databricks_debug "ActiveHelp will need delimiter"
                hasActiveHelp=1
            fi

            continue
        fi

        if [ -n "$comp" ]; then
            # If requested, completions are returned with a description.
            # The description is preceded by a TAB character.
            # For zsh's _describe, we need to use a : instead of a TAB.
            # We first need to escape any : as part of the completion itself.
            comp=${comp//:/\\:}

            local tab="$(printf '\t')"
            comp=${comp//$tab/:}

            __databricks_debug "Adding completion: ${comp}"
            completions+=${comp}
            lastComp=$comp
        fi
    done < <(printf "%s\n" "${out[@]}")

    # Add a delimiter after the activeHelp statements, but only if:
    # - there are completions following the activeHelp statements, or
    # - file completion will be performed (so there will be choices after the activeHelp)
    if [ $hasActiveHelp -eq 1 ]; then
        if [ ${#completions} -ne 0 ] || [ $((directive & shellCompDirectiveNoFileComp)) -eq 0 ]; then
            __databricks_debug "Adding activeHelp delimiter"
            compadd -x "--"
            hasActiveHelp=0
        fi
    fi

    if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
        __databricks_debug "Activating nospace."
        noSpace="-S ''"
    fi

    if [ $((directive & shellCompDirectiveKeepOrder)) -ne 0 ]; then
        __databricks_debug "Activating keep order."
        keepOrder="-V"
    fi

    if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
        # File extension filtering
        local filteringCmd
        filteringCmd='_files'
        for filter in ${completions[@]}; do
            if [ ${filter[1]} != '*' ]; then
                # zsh requires a glob pattern to do file filtering
                filter="\*.$filter"
            fi
            filteringCmd+=" -g $filter"
        done
        filteringCmd+=" ${flagPrefix}"

        __databricks_debug "File filtering command: $filteringCmd"
        _arguments '*:filename:'"$filteringCmd"
    elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
        # File completion for directories only
        local subdir
        subdir="${completions[1]}"
        if [ -n "$subdir" ]; then
            __databricks_debug "Listing directories in $subdir"
            pushd "${subdir}" >/dev/null 2>&1
        else
            __databricks_debug "Listing directories in ."
        fi

        local result
        _arguments '*:dirname:_files -/'" ${flagPrefix}"
        result=$?
        if [ -n "$subdir" ]; then
            popd >/dev/null 2>&1
        fi
        return $result
    else
        __databricks_debug "Calling _describe"
        if eval _describe $keepOrder "completions" completions $flagPrefix $noSpace; then
            __databricks_debug "_describe found some completions"

            # Return the success of having called _describe
            return 0
        else
            __databricks_debug "_describe did not find completions."
            __databricks_debug "Checking if we should do file completion."
            if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
                __databricks_debug "deactivating file completion"

                # We must return an error code here to let zsh know that there were no
                # completions found by _describe; this is what will trigger other
                # matching algorithms to attempt to find completions.
                # For example zsh can match letters in the middle of words.
                return 1
            else
                # Perform file completion
                __databricks_debug "Activating file completion"

                # We must return the result of this command, so it must be the
                # last command, or else we must store its result to return it.
                _arguments '*:filename:_files'" ${flagPrefix}"
            fi
        fi
    fi
}

# don't run the completion function when being source-ed or eval-ed
if [ "$funcstack[1]" = "_databricks" ]; then
    _databricks
fi
