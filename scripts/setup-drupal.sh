#!/usr/bin/env bash
#
# Bootstrap a Drupal installation in the CI working tree so that functional
# tests have a real, installed site to talk to.
#
# Assumes:
#   - Composer dependencies are already installed (vendor/ exists).
#   - A MySQL/MariaDB service is reachable via $SIMPLETEST_DB.
#   - The docroot is at $DRUPAL_WEB_ROOT (default: web).
#
# Exports SIMPLETEST_DB / SIMPLETEST_BASE_URL if not already set, so PHPUnit
# can pick them up.

set -euo pipefail

WEB_ROOT="${DRUPAL_WEB_ROOT:-web}"
BASE_URL="${SIMPLETEST_BASE_URL:-http://127.0.0.1:8080}"
DB_URL="${SIMPLETEST_DB:-mysql://root:root@127.0.0.1:3306/drupal}"
PROFILE="${DRUPAL_INSTALL_PROFILE:-standard}"
SITE_NAME="${DRUPAL_SITE_NAME:-CI}"

if [ ! -d "$WEB_ROOT" ]; then
  echo "ERROR: web root '$WEB_ROOT' does not exist. Set DRUPAL_WEB_ROOT or run from project root." >&2
  exit 1
fi

if [ ! -x vendor/bin/drush ]; then
  echo "ERROR: vendor/bin/drush not found. Add drush/drush to require-dev." >&2
  exit 1
fi

# Parse SIMPLETEST_DB into drush --db-url. Drush accepts the same scheme.
echo "==> Installing Drupal (profile=${PROFILE}, db=${DB_URL%%:*}://...)"
vendor/bin/drush --root="$(pwd)/${WEB_ROOT}" site:install "$PROFILE" \
  --db-url="$DB_URL" \
  --site-name="$SITE_NAME" \
  --account-name=admin \
  --account-pass=admin \
  --yes \
  --quiet

# Configure base URL for functional tests.
export SIMPLETEST_BASE_URL="$BASE_URL"
export SIMPLETEST_DB="$DB_URL"

echo "==> SIMPLETEST_BASE_URL=$SIMPLETEST_BASE_URL"
echo "==> SIMPLETEST_DB=$SIMPLETEST_DB"

# Clear caches once more for a clean slate.
vendor/bin/drush --root="$(pwd)/${WEB_ROOT}" cache:rebuild --quiet

echo "==> Drupal installed."
