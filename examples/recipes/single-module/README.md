# Recipe: single contrib-style module

Use this layout when your repository **is** a single Drupal module — the kind
of repo you'd publish to drupal.org/project/<name> and expect to be installed
via `composer require drupal/<name>`.

## Assumed layout

```
.
├── composer.json
├── src/
│   └── ...
├── tests/
│   └── src/
│       ├── Unit/
│       ├── Kernel/
│       └── Functional/
├── <name>.info.yml
├── <name>.module
└── <name>.services.yml
```

There is no `web/` directory — your module *is* the repo.

## What to copy

From `drupal-ci-templates/`:

- `github-actions/ci-minimal.yml` to `.github/workflows/ci.yml`. The full
  pipeline is overkill for a contrib module that only ships PHP and tests; the
  minimal variant covers lint + phpstan + unit, which is what drupal.org's
  built-in pipeline already exercises for kernel/functional.
- `phpstan.neon.dist`, `phpcs.xml.dist`, `phpunit.xml.dist` to the repo root.
- `scripts/run-phpstan.sh` and `scripts/run-phpcs.sh`.

## Adjustments

Edit the three config files to point at your module's own paths instead of
the default `web/modules/custom/...`:

**`phpstan.neon.dist`** — change `paths:` to:

```neon
parameters:
  paths:
    - src
  drupal:
    drupal_root: vendor/drupal/core-recommended/web
```

**`phpcs.xml.dist`** — replace the `<file>` lines with:

```xml
<file>.</file>
<exclude-pattern>*/vendor/*</exclude-pattern>
<exclude-pattern>*/tests/fixtures/*</exclude-pattern>
```

**`phpunit.xml.dist`** — change the testsuite directories to `tests/src/Unit`,
`tests/src/Kernel`, `tests/src/Functional`.

## composer.json requirements

```json
{
  "require-dev": {
    "drupal/coder": "^8.3",
    "drupal/core-dev": "^11",
    "mglaman/phpstan-drupal": "^2",
    "phpstan/phpstan": "^2",
    "phpstan/phpstan-deprecation-rules": "^2",
    "phpunit/phpunit": "^10.5"
  }
}
```

Make sure `vendor/bin` is on PATH inside the CI job — `ramsey/composer-install@v3`
takes care of that for you on GitHub Actions.
