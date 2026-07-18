# Contributing

Thanks for taking the time to contribute. This repo is small on purpose — it's
a collection of CI templates, not a framework — so the bar for changes is
*"would I want to drop this into a real Drupal project tomorrow"*.

## Ground rules

- Keep templates **runnable**. Every YAML file should pass `yamllint` and,
  where applicable, `actionlint`. The meta workflow under
  `.github/workflows/meta.yml` enforces this on every PR.
- Keep templates **minimal**. If a step isn't required to ship a Drupal site,
  it doesn't belong here. Push it to an example or a comment.
- Keep templates **honest**. No "TODO: fill in" sections without a clear
  inline explanation of what the user is meant to do.

## Local checks before opening a PR

The meta workflow (`.github/workflows/meta.yml`) lints this repo's own YAML,
workflows, and shell scripts. It delegates the actual linting to
`scripts/lint-all.sh`, so you can reproduce a CI lint failure with a single
command:

```sh
./scripts/lint-all.sh
```

That runs `yamllint`, `actionlint`, and `shellcheck` with exactly the flags and
paths CI uses. Any tool you don't have installed is skipped with a yellow
notice rather than failing the run, so you can install just what you need:

- `yamllint` — `pip install yamllint` (or `pipx install yamllint`)
- `actionlint` — see <https://github.com/rhysd/actionlint>
- `shellcheck` — your distro's package manager

Because CI and this script share the same source of truth, a clean local run is
a good predictor of a green PR.

The PHP tool configs can't be exercised without a real Drupal tree — sanity
check them against one if you can:

```sh
phpstan analyse -c phpstan.neon.dist --memory-limit=1G
phpcs --standard=phpcs.xml.dist .
```

## Branching and commits

- Branch off `main`. Use a short, hyphenated branch name: `add-pantheon-deploy`,
  `fix-phpstan-memory-limit`.
- Commit messages: imperative mood, present tense, one logical change per
  commit. `Add nightly workflow for drupal/core dev` beats `nightly`.
- Squash on merge if the PR has noisy fixup commits.

## Adding a new template

When adding a new CI platform or pipeline variant:

1. Place the file under the appropriate directory (`github-actions/`,
   `gitlab-ci/`, `bitbucket-pipelines/`, or a new one).
2. Mirror the stage names from `ci-full.yml` (`lint`, `static`, `unit`,
   `kernel`, `functional`, `security`, `deploy`) so users can switch
   platforms without re-learning the model.
3. Add an entry in `README.md`'s "What's included" tree.
4. Add an entry in `CHANGELOG.md` under `[Unreleased]`.

## Reporting issues

Open an issue with:

- The CI platform and the template file you're using.
- The Drupal/PHP version combination.
- The full failing job log, trimmed to the relevant lines.

PRs without an associated issue are fine for typos and one-line fixes.
Anything larger — please open an issue first so we can discuss the shape of
the change before you spend time on it.
