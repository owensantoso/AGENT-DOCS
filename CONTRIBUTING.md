# Contributing

Thanks for helping improve AGENT-DOCS. This project is a reusable documentation
workflow for agent-assisted repositories, so contributions should keep first-run
safety, clear handoffs, and small-project adoption in mind.

## Before You Change Files

- Read [README.md](README.md) for the workflow shape.
- Read [AGENTS.md](AGENTS.md) for repo-local agent instructions.
- Use [INSTALL.md](INSTALL.md) when changing install or adopter guidance.
- Check [plans/README.md](plans/README.md) before starting larger upstream work.

For small fixes, open a focused pull request. For larger behavior changes, add or
update the relevant `SPEC-*`, `PLAN-*`, or concept doc before implementation.

## Development Checks

Run the release check before opening a pull request when feasible:

```bash
scripts/release-check
```

For narrower edits, run the smallest relevant subset:

```bash
git diff --check
tests/install-smoke.sh
tests/agent-docs-init-smoke.sh
tests/docs-meta-smoke.sh
```

Adopter-facing changes to installer, scaffold, skills, scripts, reusable guides,
or public command behavior need a `CHANGELOG.md` entry unless the pull request
explains why `Change-Record: not-needed` applies.

## Pull Request Expectations

- Keep changes scoped to one problem.
- Preserve preview-first and non-destructive defaults.
- Do not overwrite or auto-merge project-owned Markdown in target repos.
- Update docs and verification commands in the same change when behavior changes.
- Avoid committing generated caches, local secrets, or machine-specific files.

## Release And Archive Hygiene

Source archives should be created from tracked Git content, not from a dirty
working tree. Prefer GitHub tagged source archives or:

```bash
git archive --format=tar.gz --prefix=AGENT-DOCS/ HEAD > agent-docs-source.tar.gz
```

Before publishing, run `scripts/release-check` and confirm the working tree does
not contain local caches or secrets that could be copied into a manual archive.
