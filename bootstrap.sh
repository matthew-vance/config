#!/usr/bin/env bash
# bootstrap.sh - Bootstrap script for MacOS configuration management
# Ensures the machine is ready for configuration management

set -o errexit
set -o nounset

ensure_macos() {
  if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script must be run on macOS (Darwin)." >&2
    exit 1
  fi
}

COLOR_INFO=$'\033[1;34m'
COLOR_WARN=$'\033[1;33m'
COLOR_OK=$'\033[1;32m'
COLOR_ERROR=$'\033[1;31m'
COLOR_RESET=$'\033[0m'

log() {
  local level="$1"
  local color="$2"
  shift 2
  printf '%s[%s]%s ' "$color" "$level" "$COLOR_RESET"
  printf '%s' "$@"
  printf '\n'
}

info() {
  log "INFO" "$COLOR_INFO" "$@"
}
warn() {
  log "WARN" "$COLOR_WARN" "$@"
}
ok() {
  log "OK" "$COLOR_OK" "$@"
}
error() {
  log "ERROR" "$COLOR_ERROR" "$@" >&2
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_homebrew() {
  if ! has_cmd brew; then
    if ! has_cmd bash; then
      error "bash not found, required for Homebrew installation. Please install bash and re-run this script."
      exit 1
    fi
    if ! has_cmd curl; then
      error "curl not found, required for Homebrew installation. Please install curl and re-run this script."
      exit 1
    fi
    sudo -v
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi
}

main() {
  ensure_macos
  info "Starting bootstrap process..."
  
  if ! has_cmd brew; then
    if ! has_cmd bash; then
      error "bash not found, required for Homebrew installation. Please install bash and re-run this script."
      exit 1
    fi
    if ! has_cmd curl; then
      error "curl not found, required for Homebrew installation. Please install curl and re-run this script."
      exit 1
    fi
    info "Homebrew not found. Installing Homebrew..."
    sudo -v
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ok "Homebrew installed."
  else
    info "Homebrew found. Updating Homebrew..."
    brew update
    ok "Homebrew updated."
  fi

  if [ -f "Brewfile" ]; then
    brew bundle check >/dev/null 2>&1  || {
      info "Installing packages from Brewfile..."
      brew bundle
      ok "Brewfile packages installed."
    }
  fi
 
  BREW_ZSH="$(brew --prefix)/bin/zsh"

  if ! grep -q "$BREW_ZSH" /etc/shells; then
    info "Adding Homebrew's zsh to /etc/shells..."
    echo "$BREW_ZSH" | sudo tee -a /etc/shells > /dev/null
  fi

  if [ "$(dscl . -read ~/ UserShell | awk '{print $2}')" != "$BREW_ZSH" ]; then
    info "Changing default shell to Homebrew's zsh..."
    chsh -s "$BREW_ZSH"
  fi
  ok "Default shell is set to Homebrew's zsh."

  if [ ! -L "$HOME/.stow-global-ignore" ] || [ "$(readlink "$HOME/.stow-global-ignore")" != "$PWD/dot-stow-global-ignore" ]; then
    info "Setting up GNU Stow global ignore..."
    ln -sf "$PWD/dot-stow-global-ignore" "$HOME/.stow-global-ignore"
    ok "GNU Stow setup complete."
  fi
  ok "GNU Stow global ignore set up."

  info "Bootstrap complete."
  info "You may need to restart your terminal for changes to take effect."
}

main "$@"

