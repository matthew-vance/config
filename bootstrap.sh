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

show_help() {
  cat <<EOF
Usage: ./bootstrap.sh [OPTIONS]

Bootstraps this macOS machine for configuration management.

Options:
  -h, --help    Show this help message and exit

This script performs the following actions:
  - Installs Homebrew if missing
  - Installs git if missing
  - Installs Homebrew zsh if missing
  - Adds Homebrew zsh to /etc/shells if not present
  - Sets Homebrew zsh as the default shell if not already
  - Installs just if missing
  - Installs pipx with Homebrew if missing
  - Installs Ansible (and argcomplete) with pipx if missing

All steps are idempotent and safe to run multiple times.
You may need to restart your terminal for some changes to take effect.
EOF
}

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      show_help
      exit 0
      ;;
  esac
done

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
    warn "Homebrew not found. Installing Homebrew..."
    info "Homebrew installation requires sudo access. Please enter your password when prompted."
    sudo -v
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -f /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      info "Added Homebrew to PATH"
    fi
  else
    ok "Homebrew is already installed."
  fi
}

update_homebrew() {
  info "Updating Homebrew..."
  brew update
  ok "Homebrew is up to date."
}

install_git() {
  if ! has_cmd git; then
    warn "Git not found. Installing git..."
    brew install git
  else
    ok "Git is already installed."
  fi
}

install_zsh() {
  BREW_ZSH="$(brew --prefix)/bin/zsh"
  if [ ! -x "$BREW_ZSH" ]; then
    warn "Homebrew zsh not found at %s. Installing zsh..." "$BREW_ZSH"
    brew install zsh
  else
    ok "Homebrew zsh is already installed."
  fi

  if ! grep -q "$BREW_ZSH" /etc/shells; then
    info "Adding %s to /etc/shells" "$BREW_ZSH"
    echo "$BREW_ZSH" | sudo tee -a /etc/shells > /dev/null
  fi

  if [ "$(dscl . -read ~/ UserShell | awk '{print $2}')" != "$BREW_ZSH" ]; then
    info "Setting %s as default shell" "$BREW_ZSH"
    chsh -s "$BREW_ZSH"
    info "Default shell updated. Restart your terminal to use %s." "$BREW_ZSH"
  else
    ok "Zsh is already the default shell."
  fi
}

install_just() {
  if ! has_cmd just; then
    warn "just not found. Installing just..."
    brew install just
  else
    ok "just is already installed."
  fi
}

install_pipx() {
  if ! has_cmd pipx; then
    warn "pipx not found. Installing pipx with Homebrew..."
    brew install pipx
    pipx ensurepath
  else
    ok "pipx is already installed."
  fi
}

install_ansible() {
  if ! has_cmd ansible; then
    warn "Ansible not found. Installing Ansible with pipx..."
    pipx install --include-deps ansible
    pipx inject --include-apps ansible argcomplete
  else
    ok "Ansible is already installed."
  fi
}

install_ansible_with_pipx() {
  install_pipx
  install_ansible
}

install_stow() {
  if ! has_cmd stow; then
    warn "GNU Stow not found. Installing GNU Stow..."
    brew install stow
  else
    ok "GNU Stow is already installed."
  fi
  
  if [ ! -L "$HOME/.stow-global-ignore" ] || [ "$(readlink "$HOME/.stow-global-ignore")" != "$PWD/dot-stow-global-ignore" ]; then
    info "Creating symlink for .stow-global-ignore in home directory"
    ln -sf "$PWD/dot-stow-global-ignore" "$HOME/.stow-global-ignore"
    ok "Created symlink for .stow-global-ignore in home directory"
  else
    ok "Symlink for .stow-global-ignore already exists and points to the correct target"
  fi
}

main() {
  ensure_macos
  info "Starting bootstrap process..."

  install_homebrew
  update_homebrew
  install_git
  install_zsh
  install_just
  install_ansible_with_pipx
  install_stow

  info "Bootstrap complete."
  info "You may need to restart your terminal for changes to take effect."
}

main "$@"

