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

# Print info
printf '%s[INFO]%s Starting bootstrap process...\n' "$COLOR_INFO" "$COLOR_RESET"

# Check for Homebrew and install if missing
if ! has_cmd brew; then
  printf '%s[WARN]%s Homebrew not found. Installing Homebrew...\n' "$COLOR_WARN" "$COLOR_RESET"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  printf '%s[OK]%s Homebrew is already installed.\n' "$COLOR_OK" "$COLOR_RESET"
fi

# Ensure git is installed
if ! has_cmd git; then
  printf '%s[WARN]%s Git not found. Installing git...\n' "$COLOR_WARN" "$COLOR_RESET"
  brew install git
else
  printf '%s[OK]%s Git is already installed.\n' "$COLOR_OK" "$COLOR_RESET"
fi

# Ensure zsh is installed at the Homebrew path and set as default shell if needed
BREW_ZSH="$(brew --prefix)/bin/zsh"
if [ ! -x "$BREW_ZSH" ]; then
  printf '%s[WARN]%s Homebrew zsh not found at %s. Installing zsh...\n' "$COLOR_WARN" "$COLOR_RESET" "$BREW_ZSH"
  brew install zsh
else
  printf '%s[OK]%s Homebrew zsh is already installed.\n' "$COLOR_OK" "$COLOR_RESET"
fi

# Add brew zsh to /etc/shells if not present
if ! grep -q "$BREW_ZSH" /etc/shells; then
  printf '%s[INFO]%s Adding %s to /etc/shells\n' "$COLOR_INFO" "$COLOR_RESET" "$BREW_ZSH"
  echo "$BREW_ZSH" | sudo tee -a /etc/shells > /dev/null
fi

# Change default shell if not already
if [ "$(dscl . -read ~/ UserShell | awk '{print $2}')" != "$BREW_ZSH" ]; then
  printf '%s[INFO]%s Setting %s as default shell\n' "$COLOR_INFO" "$COLOR_RESET" "$BREW_ZSH"
  chsh -s "$BREW_ZSH"
  printf '%s[INFO]%s Default shell updated. Restart your terminal to use %s.\n' "$COLOR_INFO" "$COLOR_RESET" "$BREW_ZSH"
else
  printf '%s[OK]%s Zsh is already the default shell.\n' "$COLOR_OK" "$COLOR_RESET"
fi

# Ensure just is installed
if ! has_cmd just; then
  printf '%s[WARN]%s just not found. Installing just...\n' "$COLOR_WARN" "$COLOR_RESET"
  brew install just
else
  printf '%s[OK]%s just is already installed.\n' "$COLOR_OK" "$COLOR_RESET"
fi

# Ensure Node.js (LTS) and fnm are installed

# Ensure fnm is installed
if ! has_cmd fnm; then
  printf '%s[WARN]%s fnm (Fast Node Manager) not found. Installing fnm...\n' "$COLOR_WARN" "$COLOR_RESET"
  brew install fnm
else
  printf '%s[OK]%s fnm is already installed.\n' "$COLOR_OK" "$COLOR_RESET"
fi

# Ensure latest LTS Node.js is installed and active
FNM_LATEST_LTS=$(fnm ls-remote --lts | tail -1 | awk '{print $1}')
FNM_INSTALLED_LTS=$(fnm ls | grep -Eo "v[0-9]+\\.[0-9]+\\.[0-9]+" | grep -F "$FNM_LATEST_LTS" || true)
FNM_CURRENT=$(fnm current | awk '{print $1}')

if [ -z "$FNM_INSTALLED_LTS" ]; then
  printf '%s[WARN]%s Latest LTS Node.js (%s) not installed. Installing...\n' "$COLOR_WARN" "$COLOR_RESET" "$FNM_LATEST_LTS"
  fnm install "$FNM_LATEST_LTS"
fi

if [ "$FNM_CURRENT" != "$FNM_LATEST_LTS" ]; then
  printf '%s[INFO]%s Switching to latest LTS Node.js (%s)...\n' "$COLOR_INFO" "$COLOR_RESET" "$FNM_LATEST_LTS"
  fnm use "$FNM_LATEST_LTS"
fi

# Set latest LTS as default
fnm default "$FNM_LATEST_LTS"
printf '%s[OK]%s Latest LTS Node.js (%s) is set as default.\n' "$COLOR_OK" "$COLOR_RESET" "$FNM_LATEST_LTS"


# Ensure pipx is installed
if ! has_cmd pipx; then
  printf '%s[WARN]%s pipx not found. Installing pipx with Homebrew...\n' "$COLOR_WARN" "$COLOR_RESET"
  brew install pipx
  pipx ensurepath
else
  printf '%s[OK]%s pipx is already installed.\n' "$COLOR_OK" "$COLOR_RESET"
fi

# Ensure Ansible is installed with pipx
if ! has_cmd ansible; then
  printf '%s[WARN]%s Ansible not found. Installing Ansible with pipx...\n' "$COLOR_WARN" "$COLOR_RESET"
  pipx install --include-deps ansible
  pipx inject --include-apps ansible argcomplete
else
  printf '%s[OK]%s Ansible is already installed.\n' "$COLOR_OK" "$COLOR_RESET"
fi

printf '%s[INFO]%s Bootstrap complete.\n' "$COLOR_INFO" "$COLOR_RESET"
printf '%s[INFO]%s You may need to restart your terminal for changes to take effect.\n' "$COLOR_INFO" "$COLOR_RESET"
