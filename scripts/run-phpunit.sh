#!/usr/bin/env bash
#
# Run PHPUnit against the project's phpunit.xml(.dist) configuration with a
# sane memory limit and an optional testsuite filter — the PHPUnit sibling of
# run-phpstan.sh / run-phpcs.sh, so every workflow can call one helper instead
# of copy-pasting an inline `vendor/bin/phpunit ...` invocation per provider.
#
# Usage:
#   ./scripts/run-phpunit.sh                          # run every testsuite
#   ./scripts/run-phpunit.sh --testsuite unit         # only the unit suite
#   ./scripts/run-phpunit.sh --testsuite kernel -- --filter FooTest
#   COVERAGE=1 ./scripts/run-phpunit.sh --testsuite unit
#
# The optional --testsuite argument must be one of: unit | kernel | functional.
# Anything after a `--` (or any other unrecognised argument) is forwarded
# verbatim to phpunit.
#
# Honours:
#   COVERAGE                 when truthy (1/true/yes/on), emit HTML + Clover
#                            coverage reports (needs pcov or xdebug on PHP)
#   PHPUNIT_MEMORY_LIMIT     PHP memory_limit for the run (default 512M)
#   PHPUNIT_CONFIG           config file (default phpunit.xml, then .dist)
#   PHPUNIT_COVERAGE_HTML    HTML coverage output dir (default coverage-html)
#   PHPUNIT_COVERAGE_CLOVER  Clover XML output path (default coverage.xml)

set -euo pipefail

MEMORY_LIMIT="${PHPUNIT_MEMORY_LIMIT:-512M}"
COVERAGE="${COVERAGE:-0}"

# --- Parse arguments -------------------------------------------------------
TESTSUITE=""
EXTRA_ARGS=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --testsuite)
      TESTSUITE="${2:-}"
      if [ -z "$TESTSUITE" ]; then
        echo "ERROR: --testsuite requires a value (unit|kernel|functional)." >&2
        exit 1
      fi
      shift 2
      ;;
    --testsuite=*)
      TESTSUITE="${1#*=}"
      shift
      ;;
    --)
      shift
      EXTRA_ARGS+=("$@")
      break
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

case "$TESTSUITE" in
  "" | unit | kernel | functional) ;;
  *)
    echo "ERROR: unknown testsuite '${TESTSUITE}' (expected unit|kernel|functional)." >&2
    exit 1
    ;;
esac

# --- Resolve the config file (non-.dist wins, like the sibling helpers) -----
if [ -n "${PHPUNIT_CONFIG:-}" ]; then
  CONFIG="$PHPUNIT_CONFIG"
elif [ -f phpunit.xml ]; then
  CONFIG="phpunit.xml"
elif [ -f phpunit.xml.dist ]; then
  CONFIG="phpunit.xml.dist"
else
  echo "ERROR: no phpunit.xml or phpunit.xml.dist found in $(pwd)." >&2
  exit 1
fi

if [ ! -x vendor/bin/phpunit ]; then
  echo "ERROR: vendor/bin/phpunit not found. Add phpunit/phpunit (pulled in by drupal/core-dev) to require-dev." >&2
  exit 1
fi

# --- Assemble the phpunit command ------------------------------------------
ARGS=(--configuration "$CONFIG" --colors=always)

if [ -n "$TESTSUITE" ]; then
  ARGS+=(--testsuite "$TESTSUITE")
fi

case "$COVERAGE" in
  1 | true | yes | on)
    ARGS+=(
      --coverage-html "${PHPUNIT_COVERAGE_HTML:-coverage-html}"
      --coverage-clover "${PHPUNIT_COVERAGE_CLOVER:-coverage.xml}"
    )
    ;;
esac

if [ "${#EXTRA_ARGS[@]}" -gt 0 ]; then
  ARGS+=("${EXTRA_ARGS[@]}")
fi

echo "==> PHPUnit: config=${CONFIG}${TESTSUITE:+ testsuite=${TESTSUITE}} memory=${MEMORY_LIMIT} coverage=${COVERAGE}"

exec php -d memory_limit="$MEMORY_LIMIT" vendor/bin/phpunit "${ARGS[@]}"
