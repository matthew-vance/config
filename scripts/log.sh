#!/usr/bin/env sh
# log.sh - Logging utility functions for shell scripts

# Color format variables (use ANSI escapes with $'...')
COLOR_INFO=$'\033[1;34m'
COLOR_WARN=$'\033[1;33m'
COLOR_OK=$'\033[1;32m'
COLOR_ERROR=$'\033[1;31m'
COLOR_RESET=$'\033[0m'

log() {
  # $1 = level, $2 = color, $3... = printf-style format string and arguments
  local level="$1"
  local color="$2"
  shift 2
  printf '%s[%s]%s ' "$color" "$level" "$COLOR_RESET"
  # shellcheck disable=SC2059
  printf "$@"
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
