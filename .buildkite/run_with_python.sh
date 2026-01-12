#!/usr/bin/env bash
# Wrapper that finds a usable Python interpreter and executes the given command.
#
# Preference order:
#   1. $PYTHON_BIN if the value points to an executable on PATH
#   2. python
#   3. python3
#   4. Common python3 minor versions (3.12 -> 3.8)
#
# Usage:
#   .buildkite/run_with_python.sh path/to/script.py [args]
#
# Set PYTHON_BIN to override the interpreter selection explicitly.

set -euo pipefail

_find_python() {
  if [[ -n "${PYTHON_BIN:-}" ]]; then
    if command -v "${PYTHON_BIN}" >/dev/null 2>&1; then
      echo "${PYTHON_BIN}"
      return 0
    fi
    echo "PYTHON_BIN is set to '${PYTHON_BIN}' but it is not executable" >&2
    return 1
  fi

  local -a candidates

  if [[ -n "${PYTHON_VERSION:-}" ]]; then
    candidates+=("python${PYTHON_VERSION}")
    # In case PYTHON_VERSION already has a patch component, add the shorter form
    candidates+=("python${PYTHON_VERSION%.*}")
  fi

  candidates+=(python python3 python3.12 python3.11 python3.10 python3.9 python3.8)

  for candidate in "${candidates[@]}"; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      echo "${candidate}"
      return 0
    fi
  done

  echo "Unable to locate a python executable. Set PYTHON_BIN to the interpreter path." >&2
  return 1
}

PYTHON_CMD=$(_find_python)
exec "${PYTHON_CMD}" "$@"
