# Recipe: full project (drupal/recommended-project layout)

Use this layout when your repository is a complete Drupal site — typically
scaffolded from `drupal/recommended-project` (or one of its derivatives) and
containing your `composer.json`, `composer.lock`, custom modules under
`web/modules/custom/`, and a `settings.php` you actually manage.

This is the layout `ci-full.yml` and `phpunit.xml.dist` assume by default, so
the only thing you need to do is **copy and commit**.

## Assumed layout

```
.
├── composer.json
├── composer.lock
├── .ddev/
├── web/
│   ├── core/                 # composer-managed
│   ├── modules/
│   │   ├── contrib/          # composer-managed
│   │   └── custom/
│   │       └── my_module/
│   ├── themes/
│   │   ├── contrib/
│   │   └── custom/
│   ├── profiles/
│   │   ├── contrib/
│   │   └── custom/
│   ├── sites/
│   │   └── default/
│   │       └── settings.php
│   └── index.php
└── vendor/                   # composer-managed
```

## What to copy

From `drupal-ci-templates/`:

- `github-actions/ci-full.yml` to `.github/workflows/ci.yml`.
- `github-actions/release.yml` to `.github/workflows/release.yml` (optional,
  but recommended once you tag the first release).
- `github-actions/nightly.yml` to `.github/workflows/nightly.yml` (optional —
  catches upstream Drupal breakage before it hits a stable tag).
- `phpstan.neon.dist`, `phpcs.xml.dist`, `phpunit.xml.dist` to the repo root.
- `scripts/` to `scripts/` in your repo. Make sure the executable bit is
  preserved: `git update-index --chmod=+x scripts/*.sh`.

## Adjustments

- Pick a deploy pattern in `ci-full.yml` and delete the others. See the
  top-level `README.md` "Deploy stage notes" for what each one needs.
- Add CI secrets through GitHub's UI:
  - `DEPLOY_SSH_KEY`, `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_PATH` for rsync.
  - `TERMINUS_TOKEN` for Pantheon.
  - Acquia BLT typically uses an SSH key already configured for the Acquia
    git remote — no secrets, just make sure the runner can reach
    `<sub>.code.<region>.acquia-sites.com`.

## composer.json requirements

The full pipeline expects these dev dependencies — most of them ship with
`drupal/core-dev`, but pin the static-analysis stack explicitly so PHPStan
doesn't bounce between major versions:

```json
{
  "require-dev": {
    "drupal/coder": "^8.3",
    "drupal/core-dev": "^11",
    "drush/drush": "^13",
    "friendsoftwig/twigcs": "^6",
    "mglaman/phpstan-drupal": "^2",
    "phpmd/phpmd": "^2.15",
    "phpstan/phpstan": "^2",
    "phpstan/phpstan-deprecation-rules": "^2",
    "phpunit/phpunit": "^10.5"
  }
}
```

## Local parity

Run the same checks locally before pushing:

```sh
ddev composer install
ddev exec ./scripts/run-phpcs.sh
ddev exec ./scripts/run-phpstan.sh
ddev exec vendor/bin/phpunit --testsuite=unit
```
