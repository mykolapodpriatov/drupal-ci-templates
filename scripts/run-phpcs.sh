#!/usr/bin/env bash
#
# Run PHP_CodeSniffer against custom modules and themes using the project's
# phpcs.xml(.dist) ruleset.
#
# Usage:
#   ./scripts/run-phpcs.sh                  # uses paths from the ruleset
#   ./scripts/run-phpcs.sh web/modules/custom/foo

set -euo pipefail

if [ -f phpcs.xml ]; then
  STANDARD="phpcs.xml"
elif [ -f phpcs.xml.dist ]; then
  STANDARD="phpcs.xml.dist"
else
  echo "ERROR: no phpcs.xml or phpcs.xml.dist found in $(pwd)." >&2
  exit 1
fi

if [ ! -x vendor/bin/phpcs ]; then
  echo "ERROR: vendor/bin/phpcs not found. Add squizlabs/php_codesniffer + drupal/coder to require-dev." >&2
  exit 1
fi

# Make sure phpcs knows about the Drupal standards bundled with drupal/coder.
# `coder` ships the rulesets but phpcs needs an explicit hint when run in CI.
if [ -d vendor/drupal/coder/coder_sniffer ]; then
  vendor/bin/phpcs --config-set installed_paths vendor/drupal/coder/coder_sniffer,vendor/slevomat/coding-standard >/dev/null 2>&1 || true
fi

echo "==> PHPCS: standard=${STANDARD}"

if [ "$#" -gt 0 ]; then
  vendor/bin/phpcs --standard="$STANDARD" --colors --report-width=120 "$@"
else
  vendor/bin/phpcs --standard="$STANDARD" --colors --report-width=120
fi
