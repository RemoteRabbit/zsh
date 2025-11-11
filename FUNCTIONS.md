# 🔧 Function Reference

Auto-generated documentation of all custom functions and aliases.

**Last updated:** 2025-11-11 17:20:40

---


## Performance Benchmarking

### `zsh-benchmark`

Benchmark zsh startup time

### `zsh-time`

Quick startup time check

### `zsh-profile`

Show what's slowing down startup


## Core Utilities

### `clipcopy`

Cross-platform clipboard copy

### `cdf`

Change directory with fzf (renamed from fc to avoid conflict)


### Aliases

```bash
fedi = "neonmodem"
fzfn = "fzf | xargs nvim"
ro = "cd $HOME/repos/open"
rp = "cd $HOME/repos/personal"
rw = "cd $HOME/repos/work"
so = "source $ZDOTDIR/.zshrc"
tms = "sh $HOME/.config/zsh/scripts/shell/session-wizard.sh"
vim = "nvim"
yc = "gpg-connect-agent 'scd serialno' 'learn --force' /bye"
```


## FZF Enhanced Functions

### `search`

Search file contents with ripgrep and preview

**Usage: search <pattern> [path]**

### `glog`

Interactive git log with preview

### `fpkill`

Process finder with kill option (renamed from pkill to avoid shadowing system command)

### `j`

Quick directory navigation with history

### `h`

Enhanced history search

### `f`

File finder with actions

### `env-search`

Environment variable browser


## Git Integration

### `gcheck`

Quick status check


### Aliases

```bash
g = "git"
ga = "git add"
gaa = "git add --all"
gap = "git add --patch"
gb = "git branch"
gba = "git branch --all"
gbd = "git branch --delete"
gc = "git commit"
gcm = "git commit --message"
gca = "git commit --amend"
gcf = "git commit --fixup"
gco = "git checkout"
gcob = "git checkout -b"
gd = "git diff"
gds = "git diff --staged"
gdt = "git difftool"
gf = "git fetch"
gfa = "git fetch --all"
gl = "git log"
glo = "git log --oneline"
glg = "git log --graph --oneline --decorate"
gm = "git merge"
gp = "git push"
gpf = "git push --force-with-lease"
gpl = "git pull"
gr = "git rebase"
gri = "git rebase --interactive"
gs = "git status"
gss = "git status --short"
gst = "git stash"
gstp = "git stash pop"
gstl = "git stash list"
gt = "git tag"
gw = "git worktree"
gclean = "git clean -fd"
greset = "git reset --hard"
gundo = "git reset --soft HEAD~1"
gwip = "git add -A && git commit -m 'WIP: work in progress'"
gunwip = "git log -n 1 | grep -q -c 'WIP' && git reset HEAD~1"
glp = "git log --pretty=format:'%C(yellow)%h %C(blue)%ad %C(red)%an %C(green)%s' --date=short"
gll = "git log --graph --pretty=format:'%C(yellow)%h%C(red)%d %C(reset)%s %C(blue)[%an]' --abbrev-commit"
gwhat = "git show --name-only"
gfiles = "git diff --name-only"
```


## Help & Documentation

### `zsh-help`

Main help command

**Usage: zsh-help search <term>**

### `help`

Quick function help

### `list-functions`

Show available custom functions

### `tips`

Quick tips


## Navigation & Directory Management

### `take`

Enhanced directory functions

### `ff`

Better find with fzf integration

### `edit`

Quick edit function


### Aliases

```bash
.. = "cd .."
... = "cd ../.."
.... = "cd ../../.."
..... = "cd ../../../.."
l = "ls -1"
lh = "ls -lah"
ldot = "ls -ld .*"
mkdir = "mkdir -pv"
md = "mkdir -pv"
rd = "rmdir"
home = "cd ~"
root = "cd /"
tmp = "cd /tmp"
repos = "z repos"
work = "z work"
config = "z .config"
```


## Productivity Tools

### `goto-work`

Quick project navigation functions (use different names to avoid conflicts)

### `goto-personal`

### `goto-open`

### `psg`

Enhanced process management (renamed from pgrep to avoid shadowing system command)

**Usage: psg <pattern>**

### `kill-by-pattern`

Simple process killer by pattern

**Usage: kill-by-pattern <pattern>**

### `backup`

Quick file operations

**Usage: backup <file>**

### `archive`

Quick archive creation

**Usage: archive <source> <archive_name>**

### `extract`

Quick extract

**Usage: extract <archive>**

### `sysinfo`

System information

### `port`

Port checker

**Usage: port <port_number>**

### `weather`

Weather check (requires curl)


## ⌨️ Keybindings

Custom keyboard shortcuts configured in `keybindings.zsh`.

### Vi Mode Navigation
- `H` - Beginning of line (command mode)
- `L` - End of line (command mode)
- `K` - History search backward (command mode)
- `J` - History search forward (command mode)
- `jj`, `jk` - Exit insert mode

### Command Line Editing
- `Ctrl+E` - Edit command in editor
- `Ctrl+U` - Delete from cursor to beginning of line
- `Ctrl+K` - Delete from cursor to end of line
- `Ctrl+W` - Delete word backward
- `Ctrl+Y` - Accept autosuggestion

### FZF Integration
- `Ctrl+F` - Quick file finder
- `Ctrl+J` - Quick directory jumper
- `Ctrl+G` - Start content search
- `Ctrl+R` - History search

### Utilities
- `Alt+R` - Reload zsh configuration
- `Ctrl+S Ctrl+U` - Insert sudo at line start
- `Ctrl+L` - Clear screen


---

## 📝 Notes

- This documentation is auto-generated from inline comments and function definitions
- Run `./scripts/shell/generate-docs.sh` to regenerate
- For interactive help, use `zsh-help` command
- For quick function lookup, use `list-functions` command
