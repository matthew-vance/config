#!/usr/bin/env sh
# bootstrap.sh - Bootstrap script for MacOS configuration management
# Ensures the machine is ready for configuration management as per project standards

set -e

# Color format variables (use ANSI escapes with $'...')
COLOR_INFO=$'\033[1;34m'
COLOR_WARN=$'\033[1;33m'
COLOR_OK=$'\033[1;32m'
COLOR_RESET=$'\033[0m'

show_help() {
  cat <<EOF
Usage: ./bootstrap.sh [OPTIONS]

Bootstraps this MacOS machine for configuration management.

Options:
  -h, --help    Show this help message and exit

This script ensures the following tools are installed:
  - Homebrew
  - git
  - zsh
  - just
  - fnm (Fast Node Manager)
  - Node.js (LTS)
  - Ansible

All steps are idempotent and safe to run multiple times.
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

# Check if a command exists
has_cmd() {
  command -v "$1" >/dev/null 2>&1
}


# Logging functions
log() {
  # $1 = level, $2 = color, $3... = message
  local level="$1"
  local color="$2"
  shift 2
  printf '%s[%s]%s ' "$color" "$level" "$COLOR_RESET"
  printf "%s" "$@"
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

# Print info
info "Starting bootstrap process..."

# Check for Homebrew and install if missing
if ! has_cmd brew; then
  warn "Homebrew not found. Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  ok "Homebrew is already installed."
fi

# Ensure git is installed
if ! has_cmd git; then
  warn "Git not found. Installing git..."
  brew install git
else
  ok "Git is already installed."
fi

# Ensure zsh is installed at the Homebrew path and set as default shell if needed
BREW_ZSH="$(brew --prefix)/bin/zsh"
if [ ! -x "$BREW_ZSH" ]; then
  warn "Homebrew zsh not found at %s. Installing zsh..." "$BREW_ZSH"
  brew install zsh
else
  ok "Homebrew zsh is already installed."
fi

# Add brew zsh to /etc/shells if not present
if ! grep -q "$BREW_ZSH" /etc/shells; then
  info "Adding %s to /etc/shells" "$BREW_ZSH"
  echo "$BREW_ZSH" | sudo tee -a /etc/shells > /dev/null
fi

# Change default shell if not already
if [ "$(dscl . -read ~/ UserShell | awk '{print $2}')" != "$BREW_ZSH" ]; then
  info "Setting %s as default shell" "$BREW_ZSH"
  chsh -s "$BREW_ZSH"
  info "Default shell updated. Restart your terminal to use %s." "$BREW_ZSH"
else
  ok "Zsh is already the default shell."
fi

# Ensure just is installed
if ! has_cmd just; then
  warn "just not found. Installing just..."
  brew install just
else
  ok "just is already installed."
fi

# Ensure Node.js (LTS) and fnm are installed

# Ensure fnm is installed
if ! has_cmd fnm; then
  warn "fnm (Fast Node Manager) not found. Installing fnm..."
  brew install fnm
else
  ok "fnm is already installed."
fi

# Ensure latest LTS Node.js is installed and active
FNM_LATEST_LTS=$(fnm ls-remote --lts | tail -1 | awk '{print $1}')
FNM_INSTALLED_LTS=$(fnm ls | grep -Eo "v[0-9]+\\.[0-9]+\\.[0-9]+" | grep -F "$FNM_LATEST_LTS" || true)
FNM_CURRENT=$(fnm current | awk '{print $1}')


if [ -z "$FNM_INSTALLED_LTS" ]; then
  warn "Latest LTS Node.js (%s) not installed. Installing..." "$FNM_LATEST_LTS"
  fnm install "$FNM_LATEST_LTS"
fi

if [ "$FNM_CURRENT" != "$FNM_LATEST_LTS" ]; then
  info "Switching to latest LTS Node.js (%s)..." "$FNM_LATEST_LTS"
  fnm use "$FNM_LATEST_LTS"
fi

# Set latest LTS as default
fnm default "$FNM_LATEST_LTS"
ok "Latest LTS Node.js (%s) is set as default." "$FNM_LATEST_LTS"


# Ensure pipx is installed
if ! has_cmd pipx; then
  warn "pipx not found. Installing pipx with Homebrew..."
  brew install pipx
  pipx ensurepath
else
  ok "pipx is already installed."
fi

# Ensure Ansible is installed with pipx
if ! has_cmd ansible; then
  warn "Ansible not found. Installing Ansible with pipx..."
  pipx install --include-deps ansible
  pipx inject --include-apps ansible argcomplete
else
  ok "Ansible is already installed."
fi

info "Bootstrap complete."
info "You may need to restart your terminal for changes to take effect."
