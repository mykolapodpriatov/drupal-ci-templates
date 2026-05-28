# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://example.com/drupal-ci-templates/compare/HEAD...HEAD
