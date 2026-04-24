# Testing Guide

Current verification guide for `<surface>`. This document should describe what the repo actually supports today, not an ideal future CI setup.

## What exists today

Current verification is a mix of:

- <test type>
- <test type>
- <manual or smoke type>

What does not exist yet:

- <missing automation>
- <missing automation>

## Primary commands

From the repo root:

```bash
<command>
<command>
```

## What the tests cover well

- <coverage area>
- <coverage area>
- <coverage area>

## What still needs manual checking

- <manual check>
- <manual check>

## Smoke or integration checks

```bash
<smoke command>
```

Use this as a developer sanity check, not necessarily as a release gate.

## Typical verification bundles

### Docs-only change

- Read the affected source and docs carefully.
- No mandatory command unless the docs describe runtime state that should be rechecked.

### Local feature change

```bash
<command>
<command>
```

Then run the most relevant manual checks.

### Schema or backend-adjacent change

```bash
<command>
<command>
<command>
```

## Interpreting failures

- <common failure>
- <common failure>

## Current limits to remember

- passing tests do not prove end-to-end behavior
- smoke checks do not replace UI or integration verification
