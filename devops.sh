#!/usr/bin/env bash
#
# automate.sh - Daily automation for a Node.js application.
#
# Runs the following steps in order:
#   1. Verify Node.js and npm are available
#   2. Install project dependencies
#   3. Start the application (node index.js)
#
# Exits immediately if any step fails.

set -Eeuo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
readonly SCRIPT_NAME="$(basename "$0")"
readonly APP_ENTRY="index.js"
readonly REQUIRED_NODE_MAJOR=18
readonly LOG_PREFIX="[${SCRIPT_NAME}]"

# ---------------------------------------------------------------------------
# Logging helpers
# ---------------------------------------------------------------------------
log_info()  { printf '%s [INFO]  %s\n'  "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*"; }
log_warn()  { printf '%s [WARN]  %s\n'  "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*" >&2; }
log_error() { printf '%s [ERROR] %s\n'  "$(date -u +'%Y-%m-%dT%H:%M:%SZ')" "$*" >&2; }

# ---------------------------------------------------------------------------
# Error handling
# ---------------------------------------------------------------------------
on_error() {
  local exit_code=$?
  local line_no=${1:-unknown}
  log_error "Script failed at line ${line_no} with exit code ${exit_code}."
  exit "${exit_code}"
}
trap 'on_error $LINENO' ERR

on_interrupt() {
  log_warn "Received interrupt signal. Shutting down..."
  exit 130
}
trap on_interrupt INT TERM

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Required command '${cmd}' is not installed or not in PATH."
    exit 1
  fi
}

check_environment() {
  log_info "Running pre-flight checks..."

  require_command node
  require_command npm

  local node_version
  node_version="$(node --version)"
  log_info "Detected Node.js ${node_version}"

  local npm_version
  npm_version="$(npm --version)"
  log_info "Detected npm ${npm_version}"

  local node_major
  node_major="$(node -p 'process.versions.node.split(".")[0]')"
  if (( node_major < REQUIRED_NODE_MAJOR )); then
    log_error "Node.js ${REQUIRED_NODE_MAJOR}+ is required, but ${node_version} is installed."
    exit 1
  fi

  if [[ ! -f "${APP_ENTRY}" ]]; then
    log_error "Application entry point '${APP_ENTRY}' not found in $(pwd)."
    exit 1
  fi
  log_info "Found application entry point: ${APP_ENTRY}"
}

# ---------------------------------------------------------------------------
# Steps
# ---------------------------------------------------------------------------
install_dependencies() {
  log_info "Installing dependencies (npm install)..."
  if ! npm install; then
    log_error "Dependency installation failed."
    exit 1
  fi
  log_info "Dependencies installed successfully."
}

start_application() {
  log_info "Starting application: node ${APP_ENTRY}"
  if ! node "${APP_ENTRY}"; then
    log_error "Application exited with a non-zero status."
    exit 1
  fi
  log_info "Application stopped cleanly."
}

# Stop any running Node.js processes that reference the application entry
stop_running_node() {
  log_info "Stopping any running Node.js processes for ${APP_ENTRY}..."
  local pids
  if command -v pgrep >/dev/null 2>&1; then
    pids=$(pgrep -f "node .*${APP_ENTRY}" || true)
  else
    pids=$(ps -ef | grep "node .*${APP_ENTRY}" | grep -v grep | awk '{print $2}' || true)
  fi

  if [[ -n "${pids// /}" ]]; then
    log_info "Found Node.js PIDs: ${pids}"
    if ! kill ${pids}; then
      log_warn "Graceful kill failed; forcing..."
      if ! kill -9 ${pids}; then
        log_error "Unable to kill Node.js processes"
      fi
    fi
    sleep 1
    log_info "Stopped running Node.js processes."
  else
    log_info "No running Node.js processes found for ${APP_ENTRY}."
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  log_info "Starting daily automation for Node.js application."
  check_environment
  install_dependencies
  stop_running_node
  start_application
  log_info "All tasks completed successfully."
}

main "$@"