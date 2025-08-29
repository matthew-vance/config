typeset -gU path fpath

export -U PATH path FPATH fpath MANPATH manpath
export -UT INFOPATH infopath

path=(
    $path
    $HOME/.local/bin
)

fpath=(
    $ZDOTDIR/functions
    $fpath
    $HOME/.local/share/zsh/site-functions
)

export EDITOR=${EDITOR:-"nvim"}
export VISUAL=${VISUAL:-"nvim"}

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
