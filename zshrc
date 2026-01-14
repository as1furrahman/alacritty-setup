# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                            ZSH CONFIGURATION                                 ║
# ║       Keyboard-Centric • Cross-Distro • Python/AI/ML Development Ready      ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
#
# Integrated best practices from:
#   - BreadOnPenguins/dots (modular, XDG-compliant)
#   - Cross-distro plugin paths (Arch, Debian, Ubuntu)
#   - Python/AI/ML workflow optimizations
#
# This file should be sourced from your main .zshrc:
#   source ~/Documents/alacritty/zshrc

# ─────────────────────────────────────────────────────────────────────────────────
# MODULES
# ─────────────────────────────────────────────────────────────────────────────────

zmodload zsh/complist
autoload -Uz compinit && compinit
autoload -Uz colors && colors

# ─────────────────────────────────────────────────────────────────────────────────
# LS_COLORS & EZA_COLORS - Mellifluous themed file type colors
# LS_COLORS: for standard ls and completion
# EZA_COLORS: for eza (modern ls replacement)
# ─────────────────────────────────────────────────────────────────────────────────

# Standard LS_COLORS (for ls --color and zsh completion)
export LS_COLORS="di=1;34:ln=35:so=32:pi=33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:\
*.py=33:*.pyw=33:*.ipynb=1;33:\
*.c=36:*.cpp=36:*.cc=36:*.cxx=36:*.h=36:*.hpp=36:\
*.rs=31:*.go=36:*.java=31:\
*.js=33:*.ts=34:*.jsx=33:*.tsx=34:*.vue=32:\
*.sh=32:*.bash=32:*.zsh=32:*.fish=32:\
*.toml=35:*.yaml=35:*.yml=35:*.json=35:*.xml=35:\
*.md=37:*.txt=37:*.rst=37:\
*.html=31:*.css=34:*.scss=35:\
*.lua=34:*.vim=32:*.nvim=32:\
*.git=90:*.gitignore=90:\
*.tar=1;31:*.gz=1;31:*.zip=1;31:*.7z=1;31:*.rar=1;31:\
*.jpg=35:*.jpeg=35:*.png=35:*.gif=35:*.svg=35:*.webp=35:\
*.mp3=36:*.flac=36:*.wav=36:*.mp4=36:*.mkv=36:*.avi=36:\
*.pdf=31:*.doc=31:*.docx=31:*.xls=32:*.xlsx=32:\
*.o=90:*.pyc=90:*.pyo=90:*.class=90:*.so=90:*.a=90"

# EZA_COLORS - Mellifluous file type colors for eza
# Format: "extension=color" where color is ANSI code
export EZA_COLORS="di=1;34:ln=35:ex=1;32:\
*.py=33:*.pyw=33:*.ipynb=1;33:\
*.c=36:*.cpp=36:*.cc=36:*.cxx=36:*.h=36:*.hpp=36:\
*.rs=31:*.go=36:*.java=31:\
*.js=33:*.ts=34:*.jsx=33:*.tsx=34:*.vue=32:\
*.sh=32:*.bash=32:*.zsh=32:*.fish=32:\
*.toml=35:*.yaml=35:*.yml=35:*.json=35:*.xml=35:\
*.md=37:*.txt=37:*.rst=37:\
*.html=31:*.css=34:*.scss=35:\
*.lua=34:*.vim=32:\
*.tar=1;31:*.gz=1;31:*.zip=1;31:*.7z=1;31:*.rar=1;31:\
*.jpg=35:*.jpeg=35:*.png=35:*.gif=35:*.svg=35:*.webp=35:\
*.mp3=36:*.flac=36:*.wav=36:*.mp4=36:*.mkv=36:*.avi=36:\
*.pdf=31:*.o=90:*.pyc=90"

# ─────────────────────────────────────────────────────────────────────────────────
# COMPLETION
# ─────────────────────────────────────────────────────────────────────────────────

zstyle ':completion:*' menu select                              # Tab opens menu
zstyle ':completion:*' special-dirs true                        # Show . and ..
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33  # Colorize menu
zstyle ':completion:*' squeeze-slashes false                    # Allow /*/ expansion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive

# ─────────────────────────────────────────────────────────────────────────────────
# OPTIONS
# ─────────────────────────────────────────────────────────────────────────────────

# History
setopt append_history           # Append to history on exit
setopt inc_append_history       # Write to history immediately
setopt share_history            # Share history across sessions
setopt hist_ignore_dups         # Ignore consecutive duplicates
setopt hist_ignore_space        # Ignore commands starting with space
setopt hist_reduce_blanks       # Remove superfluous blanks

# Navigation
setopt autocd                   # Type directory name to cd
setopt auto_pushd               # Make cd push old directory onto stack
setopt pushd_ignore_dups        # Don't push duplicates
setopt pushdminus               # Exchange meaning of + and -

# Completion
setopt auto_menu                # Show menu on double-tab
setopt menu_complete            # Insert first match immediately
setopt auto_param_slash         # Add trailing slash to directories

# Globbing
setopt no_case_glob             # Case insensitive globbing
setopt extended_glob            # Extended glob patterns ~ # ^
setopt globdots                 # Include dotfiles in globs

# Misc
setopt interactive_comments     # Allow # comments
unsetopt beep                   # Disable beep
stty stop undef                 # Disable Ctrl+S freeze

# ─────────────────────────────────────────────────────────────────────────────────
# HISTORY
# ─────────────────────────────────────────────────────────────────────────────────

HISTSIZE=100000
SAVEHIST=100000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_history"

# ─────────────────────────────────────────────────────────────────────────────────
# KEYBINDINGS - Emacs style with enhancements
# ─────────────────────────────────────────────────────────────────────────────────

bindkey -e                                      # Emacs keybindings

# Navigation
bindkey "^a" beginning-of-line                  # Ctrl+A: Start of line
bindkey "^e" end-of-line                        # Ctrl+E: End of line
bindkey "^[[H" beginning-of-line                # Home: Start of line
bindkey "^[[F" end-of-line                      # End: End of line
bindkey "^[[1;5C" forward-word                  # Ctrl+Right: Forward word
bindkey "^[[1;5D" backward-word                 # Ctrl+Left: Backward word

# Editing
bindkey "^H" backward-kill-word                 # Ctrl+Backspace: Delete word
bindkey "^[[3;5~" kill-word                     # Ctrl+Delete: Delete word forward
bindkey "^k" kill-line                          # Ctrl+K: Kill to end of line
bindkey "^u" backward-kill-line                 # Ctrl+U: Kill to start of line

# History
bindkey "^p" history-search-backward            # Ctrl+P: Previous matching
bindkey "^n" history-search-forward             # Ctrl+N: Next matching
bindkey "^[[A" history-search-backward          # Up: Previous matching
bindkey "^[[B" history-search-forward           # Down: Next matching

# ─────────────────────────────────────────────────────────────────────────────────
# FZF INTEGRATION (if installed)
# ─────────────────────────────────────────────────────────────────────────────────

if command -v fzf &> /dev/null; then
    # Modern fzf integration (0.48+)
    if [[ $(fzf --version | cut -d. -f1-2 | tr -d '.') -ge 48 ]]; then
        source <(fzf --zsh) 2>/dev/null
    else
        # Legacy fzf integration
        [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
        [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
        [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
        [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
    fi

    # FZF options - Mellifluous theme with bat preview
    export FZF_DEFAULT_OPTS="
        --height 50%
        --layout=reverse
        --border rounded
        --info=inline
        --color=bg+:#2d2d2d,bg:#1a1a1a,spinner:#c0af8c,hl:#a8a1be
        --color=fg:#dadada,header:#a8a1be,info:#cbaa89,pointer:#d29393
        --color=marker:#b3b393,fg+:#ffffff,prompt:#cbaa89,hl+:#a8a1be
        --color=border:#5b5b5b
        --prompt='❯ '
        --pointer='▶'
        --marker='✓'
    "
    
    # File preview with bat (if available)
    if command -v bat &> /dev/null; then
        export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview 'bat -n --color=always --line-range :300 {}' --preview-window 'right:50%:border-left'"
    fi
    
    # History widget options
    export FZF_CTRL_R_OPTS="--no-sort --preview 'echo {}' --preview-window 'down:3:wrap:border-rounded' --bind 'ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard)+abort'"
fi

# ─────────────────────────────────────────────────────────────────────────────────
# ALIASES - General
# ─────────────────────────────────────────────────────────────────────────────────

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# Listing
alias l="ls -lh --color=auto --group-directories-first"
alias ls="ls -h --color=auto --group-directories-first"
alias la="ls -lah --color=auto --group-directories-first"
alias ll="ls -lAh --color=auto --group-directories-first"

# Safety
alias mv="mv -i"
alias rm="rm -I"
alias cp="cp -i"

# Utilities
alias c="clear"
alias grep="grep --color=auto"
alias df="df -h"
alias du="du -h -d 1"
alias free="free -h"

# Modern replacements (if installed)
command -v bat &> /dev/null && alias cat="bat --style=plain"
command -v eza &> /dev/null && alias ls="eza --icons" && alias la="eza -la --icons" && alias ll="eza -l --icons"
command -v rg &> /dev/null && alias grep="rg"

# Enhanced output with bat coloring (BreadOnPenguins style)
if command -v bat &> /dev/null; then
    alias bathelp='bat --plain --language=help'
    help() { "$@" --help 2>&1 | bathelp; }
    
    # Colored system info
    alias lsblk="lsblk | bat -l fstab -p"
    alias blk="lsblk | bat -l fstab -p"
    alias freemem="free -h | bat -l fstab -p"
    alias sensors="sensors 2>/dev/null | bat -l ini -p"
    alias ports="ss -tulpn | bat -l conf -p"
    alias mounts="mount | column -t | bat -l fstab -p"
fi

# ─────────────────────────────────────────────────────────────────────────────────
# ALIASES - Python/AI/ML Workflow
# ─────────────────────────────────────────────────────────────────────────────────

alias py="python3"
alias pip="python3 -m pip"
alias act="source .venv/bin/activate"
alias deact="deactivate"

# Create and activate virtualenv
unalias venv 2>/dev/null  # Remove any existing alias
venv() {
    python3 -m venv "${1:-.venv}" && source "${1:-.venv}/bin/activate"
}

# Jupyter
alias jl="jupyter lab"
alias jn="jupyter notebook"

# GPU monitoring (AMD ROCm - from your setup)
alias gpustat="rocm-smi"
alias watch-gpu="watch -n 1 rocm-smi"

# Training helpers
alias tb="tensorboard --logdir=logs"
alias tbp="tensorboard --logdir=logs --port"

# ─────────────────────────────────────────────────────────────────────────────────
# ALIASES - Git
# ─────────────────────────────────────────────────────────────────────────────────

alias g="git"
alias gs="git status -sb"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit -v"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline -20"
alias glog="git log --graph --oneline --decorate"
alias gb="git branch"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gst="git stash"
alias gstp="git stash pop"

# ─────────────────────────────────────────────────────────────────────────────────
# PLUGINS - Cross-distro compatible loading
# ─────────────────────────────────────────────────────────────────────────────────

# Syntax highlighting
_syntax_highlight_paths=(
    "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "${HOMEBREW_PREFIX:-/usr/local}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
)
for _path in "${_syntax_highlight_paths[@]}"; do
    if [[ -f "$_path" ]]; then
        source "$_path"
        break
    fi
done

# Autosuggestions
_autosuggestions_paths=(
    "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "${HOMEBREW_PREFIX:-/usr/local}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
)
for _path in "${_autosuggestions_paths[@]}"; do
    if [[ -f "$_path" ]]; then
        source "$_path"
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
        break
    fi
done

# Cleanup
unset _syntax_highlight_paths _autosuggestions_paths _path

# ─────────────────────────────────────────────────────────────────────────────────
# STARSHIP PROMPT
# ─────────────────────────────────────────────────────────────────────────────────

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# ─────────────────────────────────────────────────────────────────────────────────
# ZOXIDE - Smart cd (z command)
# ─────────────────────────────────────────────────────────────────────────────────

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z"      # Replace cd with z
fi

# ─────────────────────────────────────────────────────────────────────────────────
# THEFUCK - Auto-correct commands
# ─────────────────────────────────────────────────────────────────────────────────

if command -v thefuck &> /dev/null; then
    # Suppress errors for Python 3.12 compatibility issues
    eval "$(thefuck --alias 2>/dev/null)" || true
    eval "$(thefuck --alias fix 2>/dev/null)" || true
fi

# ─────────────────────────────────────────────────────────────────────────────────
# YAZI - File manager (y to open, cd on exit)
# ─────────────────────────────────────────────────────────────────────────────────

if command -v yazi &> /dev/null; then
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
        fi
        rm -f -- "$tmp"
    }
fi



# Ensure local bin is in PATH
export PATH="$HOME/.local/bin:$PATH"



# ─────────────────────────────────────────────────────────────────────────────────
# COLORED MAN PAGES
# ─────────────────────────────────────────────────────────────────────────────────

export LESS="-R"
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'
export LESS_TERMCAP_ue=$'\E[0m'

# ─────────────────────────────────────────────────────────────────────────────────
# HELPER FUNCTIONS
# ─────────────────────────────────────────────────────────────────────────────────

# Make directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *.rar)     unrar x "$1" ;;
            *)         echo "Unknown archive format: $1" ;;
        esac
    else
        echo "File not found: $1"
    fi
}

# Quick find
ff() {
    find . -type f -iname "*$1*" 2>/dev/null
}

# Quick find directory
fd() {
    find . -type d -iname "*$1*" 2>/dev/null
}

# Show PATH entries
path() {
    echo "$PATH" | tr ':' '\n'
}

# ─────────────────────────────────────────────────────────────────────────────────
# STARTUP GREETING (BreadOnPenguins style)
# ─────────────────────────────────────────────────────────────────────────────────

# Minimal greeting with system info - only for interactive shells
if [[ $- == *i* ]]; then
    # Detect distro name
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        _distro="${ID:-linux}"
    else
        _distro="linux"
    fi

    # Colors matching Mellifluous theme
    _greet_time="\e[38;5;174m"      # Warm red for time
    _greet_uptime="\e[38;5;180m"    # Warm yellow for uptime  
    _greet_distro="\e[38;5;223m"    # Cream for distro
    _greet_reset="\e[0m"
    
    # Minimal one-line greeting
    echo -e "${_greet_time} $(date +%_I:%M%P)${_greet_reset}  ${_greet_uptime}󰅐 $(uptime -p | sed 's/up //')${_greet_reset}  ${_greet_distro} ${_distro} in ~${_greet_reset}"
    
    unset _greet_time _greet_uptime _greet_distro _greet_reset _distro
fi
