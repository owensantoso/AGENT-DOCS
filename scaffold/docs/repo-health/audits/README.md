# Repo Health Audits

Use this folder for periodic project checkups.

Repo health audits are broader than docs audits. They can include:

- docs metadata and generated views
- stale docs and roadmap order
- architecture boundaries and `AREA-*` drift
- duplicated code or repeated patterns
- refactor opportunities
- test, lint, build, and CI health
- dependency, release, security, or operations hygiene
- open issue/PR paper-trail quality

Audits are receipts, not generated truth. Generated signals such as `HEALTH.md`, `ROADMAP-VIEW.md`, `TODOS.md`, and `DOCS-REGISTRY.md` can feed an audit, but the audit records what a human or agent actually checked and concluded.

Recommended cadence:

- small active repo: every 1-2 weeks
- fast-moving repo: after major milestones
- quiet repo: before restarting meaningful work

## Workflow

Start from `YYYY-MM-DD-repo-health-audit.md`.

Typical commands:

```bash
scripts/docs-meta check
scripts/docs-meta health --write
scripts/docs-meta roadmap --write
```

Then add project-specific checks such as tests, lint, build, architecture review, duplication search, dependency checks, or manual review.

## Last Audit

- Last completed audit:
- Next suggested audit:

Update these pointers after completing a meaningful audit. `docs-meta health` can also flag when completed audits are missing or old.
