typeset -gU path fpath manpath infopath
export -U PATH path FPATH fpath MANPATH manpath
export -UT INFOPATH infopath

if [[ -d /opt/homebrew ]]; then
    eval "$('/opt/homebrew/bin/brew' shellenv)"
    fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

export ANDROID_HOME="$HOME/Library/Android/sdk"

path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    "/opt/homebrew/opt/llvm/bin"
    "$HOME/go/bin"
    "$HOME/Library/Application Support/fnm"
    "$ANDROID_HOME/emulator"
    "$ANDROID_HOME/platform-tools"
    $path
)

fpath=(
    "${ZDOTDIR:-$HOME/.config/zsh}/functions"
    "$HOME/.local/share/zsh/site-functions"
    $fpath
)
