#!/usr/bin/env bash
#
# Run PHPStan against Drupal custom modules with a generous memory limit
# and the project's phpstan.neon(.dist) configuration.
#
# Usage:
#   ./scripts/run-phpstan.sh                  # uses default paths from config
#   ./scripts/run-phpstan.sh web/modules/custom/foo
#
# Honours PHPSTAN_MEMORY_LIMIT (default 1G) and PHPSTAN_CONFIG (default
# phpstan.neon, falling back to phpstan.neon.dist).
#
# If PHPSTAN_REPORT is set, a JUnit report is written to that path (consumed
# as a CI artifact, e.g. GitLab's phpstan-report.xml); otherwise findings are
# printed as a human-readable table.

set -euo pipefail

MEMORY_LIMIT="${PHPSTAN_MEMORY_LIMIT:-1G}"
REPORT_FILE="${PHPSTAN_REPORT:-}"

if [ -n "$REPORT_FILE" ]; then
  ERROR_FORMAT="junit"
else
  ERROR_FORMAT="table"
fi

if [ -n "${PHPSTAN_CONFIG:-}" ]; then
  CONFIG="$PHPSTAN_CONFIG"
elif [ -f phpstan.neon ]; then
  CONFIG="phpstan.neon"
elif [ -f phpstan.neon.dist ]; then
  CONFIG="phpstan.neon.dist"
else
  echo "ERROR: no phpstan.neon or phpstan.neon.dist found in $(pwd)." >&2
  exit 1
fi

if [ ! -x vendor/bin/phpstan ]; then
  echo "ERROR: vendor/bin/phpstan not found. Add phpstan/phpstan + mglaman/phpstan-drupal to require-dev." >&2
  exit 1
fi

echo "==> PHPStan: config=${CONFIG} memory=${MEMORY_LIMIT} format=${ERROR_FORMAT}${REPORT_FILE:+ report=${REPORT_FILE}}"

run_phpstan() {
  vendor/bin/phpstan analyse \
    --configuration="$CONFIG" \
    --memory-limit="$MEMORY_LIMIT" \
    --no-progress \
    --error-format="$ERROR_FORMAT" \
    "$@"
}

if [ -n "$REPORT_FILE" ]; then
  run_phpstan "$@" > "$REPORT_FILE"
else
  run_phpstan "$@"
fi
