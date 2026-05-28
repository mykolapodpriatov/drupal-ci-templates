# Recipe: monorepo of custom modules

Use this layout when one repository contains a Drupal site **plus** multiple
independently-versioned custom modules, each with its own test suite and the
expectation that a change to one module won't trigger the full test matrix
across the others.

## Assumed layout

```
.
├── composer.json
├── web/
│   ├── core/
│   ├── modules/
│   │   ├── contrib/
│   │   └── custom/
│   │       ├── foo/
│   │       ├── bar/
│   │       └── baz/
│   ├── themes/
│   └── ...
└── vendor/
```

Each custom module ships its own `tests/` tree, and tests are tagged with
`@group <module_name>` so PHPUnit can target them individually.

## What to copy

From `drupal-ci-templates/`:

- `github-actions/ci-monorepo.yml` to `.github/workflows/ci.yml`.
- The standard configs (`phpstan.neon.dist`, `phpcs.xml.dist`,
  `phpunit.xml.dist`) and the `scripts/` directory.

If you're on GitLab instead, copy `gitlab-ci/templates/php-job.yml` and write
your own `.gitlab-ci.yml` that includes it; the `include:` form lets each
sub-pipeline opt into whichever jobs it needs.

## Adjustments

Open `ci-monorepo.yml` and edit the `filters:` block under `changes:` so each
custom module gets its own entry:

```yaml
module_foo:
  - 'web/modules/custom/foo/**'
module_bar:
  - 'web/modules/custom/bar/**'
```

Then duplicate the `test-foo` job per module, swapping the `if:` condition and
the `--group=<name>` argument. The template ships with three modules pre-wired
(`foo`, `bar`, `baz`) — delete or rename them.

## Tagging tests

Every test class in `web/modules/custom/<name>/tests/` should carry a `@group`
annotation matching the module name. Example for `web/modules/custom/foo/tests/src/Unit/FooServiceTest.php`:

```php
/**
 * @group foo
 * @coversDefaultClass \Drupal\foo\FooService
 */
final class FooServiceTest extends UnitTestCase {
  // ...
}
```

That's what the `vendor/bin/phpunit --group=foo` filter in the workflow keys
on.

## Why not just run everything every time?

Because in a monorepo with ten custom modules, a one-line README change to
`foo` should not also re-run kernel/functional tests for `bar` and `baz`.
With path filtering each touched module costs only its own job; the lint job
remains shared because a phpcs ruleset change should re-lint everything.

## composer.json requirements

Same as the project-template recipe — the only difference is that
`phpunit.xml.dist` discovers all `web/modules/custom/*/tests/` directories at
once. You don't need a separate `phpunit.xml` per module.
