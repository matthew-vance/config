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

main() {
  ensure_macos
  info "Starting bootstrap process..."

  if ! has_cmd nix; then
    error "Nix package manager not found. Please install Nix using `curl -fsSL https://install.determinate.systems/nix | sh -s -- install --prefer-upstream-nix` and re-run this script."
    exit 1
  else
    ok "Nix package manager found."
  fi
  
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
    ok "Homebrew found."
    info "Updating Homebrew..."
    brew update
    ok "Homebrew updated."
  fi

  info "Setting up nix-darwin..."
  sudo nix run 'nix-darwin/master#darwin-rebuild' -- switch --flake "$HOME/code/config/nix"
  ok "nix-darwin setup complete."

  ok "Bootstrap complete."
  info "You may need to restart your terminal for changes to take effect."
}

main "$@"

