#!/usr/bin/env bash
#
# Run the same lint checks the meta CI workflow runs — locally.
#
# This is the single source of truth for HOW this repo lints itself:
# .github/workflows/meta.yml installs the tools and then delegates to this
# script, so a contributor who runs it locally reproduces exactly what CI
# does and the two can't drift apart.
#
# Each linter runs only if its binary is on PATH. A missing tool prints a
# yellow "skipping" notice and does NOT fail the run (so you can lint just the
# YAML without installing actionlint, etc.). Any real lint failure makes the
# whole run exit non-zero.
#
# Usage:
#   ./scripts/lint-all.sh
#
# Tools (install locally to match CI):
#   - yamllint     pip install yamllint     (or: pipx install yamllint)
#   - actionlint   https://github.com/rhysd/actionlint
#   - shellcheck   your distro's package manager

set -uo pipefail

# Run from the repo root regardless of the caller's working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT" || exit 1

# Colours, disabled when stdout is not a TTY (e.g. piped into CI logs).
if [ -t 1 ]; then
  YELLOW=$'\033[33m'
  GREEN=$'\033[32m'
  RED=$'\033[31m'
  RESET=$'\033[0m'
else
  YELLOW=''
  GREEN=''
  RED=''
  RESET=''
fi

status=0

skip() {
  printf '%s==> skipping %s: not installed (%s)%s\n' "$YELLOW" "$1" "$2" "$RESET"
}

# The set of paths yamllint checks — kept in lock-step with the file_or_dir
# list in .github/workflows/meta.yml.
YAMLLINT_PATHS=(
  .github/workflows
  github-actions
  gitlab-ci
  bitbucket-pipelines
  circleci
)

# --- yamllint --------------------------------------------------------------
if command -v yamllint >/dev/null 2>&1; then
  echo "==> yamllint"
  if ! yamllint -c .yamllint.yml "${YAMLLINT_PATHS[@]}"; then
    status=1
  fi
else
  skip yamllint "pip install yamllint"
fi

# --- actionlint ------------------------------------------------------------
# The workflows under .github/workflows are linted with actionlint's built-in
# shell linting (uses shellcheck if it is on PATH); the distributed templates
# under github-actions/ are linted with `-shellcheck=` so contributors' own
# ${{ ... }} interpolations aren't flagged as shell issues.
if command -v actionlint >/dev/null 2>&1; then
  echo "==> actionlint (.github/workflows)"
  if ! actionlint -color .github/workflows/*.yml; then
    status=1
  fi
  echo "==> actionlint (github-actions templates)"
  if ! actionlint -color -shellcheck= github-actions/*.yml; then
    status=1
  fi
else
  skip actionlint "https://github.com/rhysd/actionlint"
fi

# --- shellcheck ------------------------------------------------------------
if command -v shellcheck >/dev/null 2>&1; then
  echo "==> shellcheck"
  if ! shellcheck scripts/*.sh; then
    status=1
  fi
else
  skip shellcheck "https://www.shellcheck.net"
fi

if [ "$status" -eq 0 ]; then
  printf '%s==> all lint checks passed%s\n' "$GREEN" "$RESET"
else
  printf '%s==> lint failures reported above%s\n' "$RED" "$RESET"
fi

exit "$status"
