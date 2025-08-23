#!/usr/bin/env sh
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


SCRIPTS_DIR="$(dirname "$0")/scripts"
# shellcheck source=scripts/log.sh
. "$SCRIPTS_DIR/log.sh"

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
  - Installs fnm (Fast Node Manager) if missing
  - Installs the latest LTS version of Node.js using fnm and sets it as default
  - Installs zx globally with npm if missing
  - Installs pyenv if missing
  - Installs latest Python version with pyenv and sets it as default
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
    if ! has_cmd curl; then
      error "curl not found, required for Homebrew installation. Please install curl and re-run this script."
      exit 1
    fi
    warn "Homebrew not found. Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    ok "Homebrew is already installed."
  fi
}

update_homebrew() {
  info "Updating Homebrew..."
  brew update
  ok "Homebrew is up to date."
}

run_brew_doctor() {
  info "Running Homebrew doctor..."
  local BREW_DOCTOR_OUTPUT=""
  local BREW_DOCTOR_EXIT=0
  BREW_DOCTOR_OUTPUT=$( (brew doctor) 2>&1 ) || BREW_DOCTOR_EXIT=$?
  echo "$BREW_DOCTOR_OUTPUT" >&2
  if [ "$BREW_DOCTOR_EXIT" -eq 0 ]; then
    ok "Homebrew doctor completed."
  fi
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

install_fnm() {
  if ! has_cmd fnm; then
    warn "fnm (Fast Node Manager) not found. Installing fnm..."
    brew install fnm
  else
    ok "fnm is already installed."
  fi
}

install_latest_node() {
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

  fnm default "$FNM_LATEST_LTS"
  ok "Latest LTS Node.js (%s) is set as default." "$FNM_LATEST_LTS"
}

install_zx() {
  if ! has_cmd zx; then
    warn "zx not found. Installing zx globally with npm..."
    npm install -g zx
  else
    ok "zx is already installed globally."
  fi
}

install_pyenv() {
  if ! has_cmd pyenv; then
    warn "pyenv not found. Installing pyenv with Homebrew..."
    brew install pyenv
  else
    ok "pyenv is already installed."
  fi

  if command -v pyenv 1>/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
  fi
}

install_latest_python() {
  PYENV_LATEST=$(pyenv install --list | grep -E '^  [0-9]+\.[0-9]+\.[0-9]+$' | tr -d ' ' | grep -v - | tail -1)
  PYENV_INSTALLED=$(pyenv versions --bare | grep -F "$PYENV_LATEST" || true)
  PYENV_GLOBAL=$(pyenv global 2>/dev/null | head -1)

  if [ -z "$PYENV_INSTALLED" ]; then
    warn "Latest Python ($PYENV_LATEST) not installed. Installing..."
    pyenv install "$PYENV_LATEST"
  fi

  if [ "$PYENV_GLOBAL" != "$PYENV_LATEST" ]; then
    info "Setting latest Python ($PYENV_LATEST) as global default..."
    pyenv global "$PYENV_LATEST"
  fi

  ok "Latest Python ($PYENV_LATEST) is set as global default."
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

main() {
  ensure_macos
  info "Starting bootstrap process..."
  install_homebrew
  update_homebrew
  run_brew_doctor
  install_git
  install_zsh
  install_just
  install_fnm
  install_latest_node
  install_zx
  install_pyenv
  install_latest_python
  install_pipx
  install_ansible

  if [ "${BREW_DOCTOR_EXIT:-0}" -ne 0 ]; then
    warn "brew doctor reported issues. Review the output above."
  fi

  info "Bootstrap complete."
  info "You may need to restart your terminal for changes to take effect."
}

main "$@"

