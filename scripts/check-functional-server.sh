#!/usr/bin/env bash
#
# Functional jobs serve Drupal through PHP's built-in server. Without the
# scaffold router, only "/" hits index.php and every other clean URL is a
# server 404, so browser tests never reach Drupal.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

hits="$(grep -R -n --include='*.yml' 'php -S' \
  github-actions gitlab-ci circleci azure-pipelines bitbucket-pipelines || true)"

if [ -z "$hits" ]; then
  echo "no php -S lines found in the CI templates" >&2
  exit 1
fi

bad=0
while IFS= read -r line; do
  case "$line" in
    *.ht.router.php*) ;;
    *)
      echo "functional server is missing .ht.router.php: $line" >&2
      bad=1
      ;;
  esac
done <<EOF
$hits
EOF

exit "$bad"
