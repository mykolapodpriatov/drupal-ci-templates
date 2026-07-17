# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `scripts/lint-all.sh` runs the meta-CI checks (yamllint, actionlint,
  shellcheck) locally with the same flags and paths as CI; missing tools are
  skipped with a notice instead of failing.
- CircleCI template at `circleci/config.yml` mirroring `ci-full.yml`
  (lint / phpstan / unit / kernel / functional / deploy) with a MySQL service
  and the PHP 8.2 x Drupal ^10.3 / PHP 8.3 x Drupal ^11 pairing.

### Changed
- Matrix excludes the impossible PHP 8.2 × Drupal `^11` pairing across the
  GitHub Actions, GitLab CI, and Bitbucket templates.
- `.github/workflows/meta.yml` now delegates linting to `scripts/lint-all.sh`
  so CI and local runs share a single source of truth.

## [1.0.0] - 2026-06-22

### Added
- Initial repository structure, README, license, and contribution guide.
- GitHub Actions workflows: `ci-full.yml`, `ci-minimal.yml`, `ci-monorepo.yml`,
  `release.yml`, `nightly.yml`.
- GitLab CI templates: full pipeline, minimal variant, and a reusable
  `templates/php-job.yml` for `include:`-based monorepos.
- Bitbucket Pipelines template covering the same lint / test / deploy flow
  using parallel steps in place of a matrix.
- Shared shell helpers under `scripts/` for Drupal bootstrap, PHPStan, PHPCS,
  and a MySQL readiness wait loop.
- Tool baselines: `phpstan.neon.dist` (level 8 + `mglaman/phpstan-drupal`),
  `phpcs.xml.dist` (Drupal + DrupalPractice), `phpunit.xml.dist` with three
  testsuites.
- Drop-in recipes under `examples/recipes/` for single-module, project-template,
  and monorepo layouts.
- Meta workflow at `.github/workflows/meta.yml` that runs `yamllint` and
  `actionlint` against the templates themselves.

[Unreleased]: https://github.com/mykolapodpriatov/drupal-ci-templates/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/mykolapodpriatov/drupal-ci-templates/releases/tag/v1.0.0
