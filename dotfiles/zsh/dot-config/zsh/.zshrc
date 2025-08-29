has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# history
HISTFILE=$HOME/.local/share/zsh/history

[[ -d $HISTFILE:h ]] ||
  mkdir -p "$HISTFILE":h

SAVEHIST=$(( 100 * 1000 ))
HISTFILESIZE=$(( (12 * SAVEHIST) / 10 ))
HISTSIZE=$(( (12 * SAVEHIST) / 10 ))

setopt HIST_FCNTL_LOCK
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt SHARE_HISTORY

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

setopt ALWAYS_TO_END
setopt AUTO_LIST
setopt AUTO_MENU
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
setopt EXTENDED_GLOB
unsetopt FLOW_CONTROL
unsetopt MENU_COMPLETE

setopt NUMERIC_GLOB_SORT

setopt INTERACTIVE_COMMENTS
setopt HASH_EXECUTABLES_ONLY

if has_cmd bat; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi


# https://junegunn.github.io/fzf/
if has_cmd fzf; then
  # Preview file content using bat (https://github.com/sharkdp/bat)
  export FZF_CTRL_T_OPTS="
    --walker-skip .git,node_modules,target
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"

  # CTRL-Y to copy the command into clipboard using pbcopy
  export FZF_CTRL_R_OPTS="
    --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
    --color header:italic
    --header 'Press CTRL-Y to copy command into clipboard'"

  # catppuccin mocha theme
  export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --color=selected-bg:#45475a \
  --multi"

  source <(fzf --zsh)
fi

if has_cmd fnm; then
  eval "$(fnm env --use-on-cd)"
fi

ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d $ZSH_COMPDUMP:h ]] || mkdir -p "$ZSH_COMPDUMP":h


# plugins
antidote_dir="$HOME/.antidote"
[[ -d $antidote_dir ]] ||
  git clone https://github.com/mattmc3/antidote "$antidote_dir"

source $antidote_dir/antidote.zsh
antidote load


# aliases
alias -g ...="../.."
alias -g ....="../../.."
alias -g .....="../../../.."
alias -g ......="../../../../.."

alias cd..='cd ..'
alias -- -="cd -"
alias 1="cd -1"
alias 2="cd -2"
alias 3="cd -3"
alias 4="cd -4"
alias 5="cd -5"
alias 6="cd -6"
alias 7="cd -7"
alias 8="cd -8"
alias 9="cd -9"

alias h="history"
alias h1="history -10"
alias h2="history -20"
alias h3="history -30"
alias hs="history | fzf --border --height 50% | copy"

alias copy="pbcopy"
alias paste="pbpaste"

alias a="alias | fzf --border --height 50% | rg -o '^[^=]+' | copy"
alias c="clear"

alias v='nvim'

alias ip="curl -s https://icanhazip.com; echo"

alias ls='eza --oneline --classify --color=automatic --icons --time-style=long-iso --group-directories-first'
alias la='ls --all'
alias ll='ls --all --long --header --binary'
alias sl="ls"

alias lg="lazygit"
alias lzd="lazydocker"

alias uuid="uuidgen | tr '[:upper:]' '[:lower:]'"
alias uuidc="uuid | copy"

alias so="source ${ZDOTDIR}/.zshrc"

alias path="echo ${PATH} | tr ':' '\n'"
alias spath="path | fzf --border --height 50% | copy"

alias ping="ping -c 5"

alias now='date +"%T"'

alias tf="terraform"
alias k="kubectl"
alias d="docker"
alias dc="docker-compose"
alias dr="docker run -it --rm"

alias bupa="brew update && brew upgrade && brew cleanup && brew doctor"

# What's running on this port?
function rop() {
  lsof -nP -iTCP:"$1" -sTCP:LISTEN
}

# Yazi shell wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

has_cmd docker && eval "$(docker completion zsh)"
has_cmd kubectl && source <(kubectl completion zsh)
has_cmd zoxide && eval "$(zoxide init zsh --cmd cd)"
has_cmd op && eval "$(op completion zsh)" # This is what makes the terminal ask to access data from other applications
has_cmd sdk && source "$HOME/.sdkman/bin/sdkman-init.sh"

# 1password ssh-agent integration
if [[ -f "$HOME/.agent-bridge.sh" ]]; then
    source "$HOME/.agent-bridge.sh"
fi

if has_cmd pyenv; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
fi


[[ -f "$ZDOTDIR/local/local.zsh" ]] && source "$ZDOTDIR/local/local.zsh"

has_cmd starship && eval "$(starship init zsh)"
